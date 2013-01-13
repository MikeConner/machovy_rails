require 'utilities'
require 'weighting_factory'
require 'promotion_strategy_factory'

class PromotionsController < ApplicationController  
  respond_to :html, :js

  include ApplicationHelper
  
  before_filter :authenticate_user!, :except => [:show]
  # SuperAdmins and ContentAdmins can do these functions
  before_filter :ensure_vendor, :only => [:index, :new, :create]
  # Only SuperAdmins (and vendors) can edit local deals
  before_filter :ensure_vendor_or_super_admin, :only => [:edit]
  before_filter :ensure_correct_vendor, :only => [:edit, :show_logs, :accept_edits, :reject_edits]
  before_filter :admin_only, :only => [:manage, :affiliates]
  before_filter :validate_eligible, :only => [:order]
  before_filter :transform_prices, :only => [:create, :update]
  
  load_and_authorize_resource

  # GET /promotions
  # NOTES AND WARNINGS
  #   Logic assumes there is one "Merchant" role and anything else is Machovy; revisit if this changes
  def index
    # Approved promotions (could still be expired!)     
    # These have different meanings for admins and vendors
    # For a vendor, only that vendor's promotions are included, and "attention" means attention by the vendor
    # For admins, all promotions from all vendors are included, and "attention" means attention by Machovy
    # The controller then displays either the vendor or the admin view
    #
    # There could of course be separate actions instead of using the same action; it's a design decision to make it the same action
    #  because 1) it's "morally" an index action for both types of users; the distinction is on the user, not the indexed object; and
    #          2) there's going to be duplication in any case; if the similar code blocks are next to each other hopefully they'll be
    #             maintained better. 
    @live = []
    @pending = []
    @attention = []
    @inactive = []
    # ads will be empty for admins
    @ads = []
    
    # Generalize this a bit to accommodate future roles. The essential distinction is between Merchants and Machovy,
    #   so check for Merchant explicitly, and let all other roles (including future ones) be "Machovy". 
    # Last ditch check to make sure customers never see this, though CanCan should prevent it anyway
    if current_user.has_role?(Role::MERCHANT)
      vendor = current_user.vendor
      # filters should ensure this isn't nil, but don't want to throw an exception here
      if !vendor.nil?
        vendor.promotions.deals.each do |promotion|
          if promotion.approved?
            if promotion.displayable?
              @live.push(promotion)
            else
              @inactive.push(promotion)
            end
          elsif promotion.suspended? or promotion.awaiting_machovy_action?
            @pending.push(promotion)
          elsif promotion.awaiting_vendor_action?
            @attention.push(promotion)
          else
            # Should never happen -- catch it if somebody adds a status, doesn't update the tests, *and* doesn't update the controller
            raise RangeError, "Unknown status: #{promotion.status}"
          end
        end
        
        @ads = vendor.promotions.ads
      end
    elsif !current_user.is_customer? # Assume any other status is Machovy -- Super Admin/Content Admin
      # Nothing to do for ads or affiliates, so don't include them
      Promotion.deals.each do |promotion|
        if promotion.approved?
          if promotion.displayable?
            @live.push(promotion)
          else
            @inactive.push(promotion)
          end
        elsif promotion.awaiting_vendor_action?
          @pending.push(promotion)
        elsif promotion.awaiting_machovy_action?
          @attention.push(promotion)
        else
          # Should never happen -- catch it if somebody adds a status, doesn't update the tests, *and* doesn't update the controller
          raise RangeError, "Unknown status: #{promotion.status}"
        end
      end
      
      render 'index_admin', :layout => 'layouts/admin' and return
    else
      redirect_to root_path, :alert => 'admins_only'
    end
  end

  # GET /promotions/1
  def show
    @promotion = Promotion.find(params[:id])
    # WARNING!
    # When assigning booleans, need to use ||, not OR operator. If you change to and/or it will break!
    @show_buy_button = eligible_to_purchase(@promotion)
    @show_terms = !current_user.nil? && !current_user.is_customer?
    @show_accept_reject = !current_user.nil? && current_user.has_role?(Role::MERCHANT) && @promotion.status == Promotion::EDITED && !@promotion.suspended?
    @curators = @promotion.curators
    if @curators.length > 4
      @curators = @curators[0, 4]
    end
    # Ignore for now logging stuff for users who aren't logged in
    if !current_user.nil? and current_user.is_customer?
      current_user.log_activity(@promotion)
    end
  end

  def accept_edits
    # before_filter has already set @promotion
    if @promotion.update_attributes(:status => Promotion::VENDOR_APPROVED)
      @promotion.promotion_logs.create(:status => Promotion::VENDOR_APPROVED, :comment => "Accepted by vendor (#{current_user.email})")
      redirect_to promotions_path, :notice => I18n.t('promotion_accept_edits')
    else
      redirect_to @promotion, :alert => I18n.t('promotion_update_error')
    end
  end
  
  def reject_edits
    # before_filter has already set @promotion
    if @promotion.update_attributes(:status => Promotion::VENDOR_REJECTED)
      @promotion.promotion_logs.create(:status => Promotion::VENDOR_REJECTED, :comment => params[:comment] + "\n - #{current_user.email}")
      redirect_to promotions_path, :notice => I18n.t('promotion_reject_edits')
    else
      redirect_to @promotion, :alert => I18n.t('promotion_update_error')
    end
  end
  
  # filter has already set @promotion
  def show_logs
    @logs = @promotion.promotion_logs
  end
  
  # GET /promotions/1/order
  def order    
    # @promotion set by before_filter 
    fine_print = @promotion.limitations.nil? && @promotion.voucher_instructions.nil? ? nil : 
                 @promotion.limitations.to_s + "\n" + @promotion.voucher_instructions.to_s
                
    @order = @promotion.orders.build(:user_id => current_user.id, :email => current_user.email, :fine_print => fine_print,
                                     :quantity => @promotion.min_per_customer, :amount => @promotion.price, 
                                     :description => "#{@promotion.vendor.name} promo #{@promotion.title} #{Date.today.to_s}")
                                     
    # Pass in stripe Customer object if there is one
    #TODO Handle with Vault
    @stripe_customer = nil; #current_user.stripe_customer_obj
  end

  # GET /promotions/new
  def new
    # Don't order metros by name, or Pittsburgh won't be first
    @metros = Metro.all
    @vendors = Vendor.order(:name)
    @categories = Category.order(:name)
    
    @promotion = Promotion.new
    # Required to support nested attributes
    @promotion.promotion_images.build
    # Merchants should render default "new"
    if current_user.has_role?(Role::MERCHANT)
      # For now, merchants can only create local deals
      # If they can create ads later, just redirect to new_ad instead
      if params[:promotion_type] != Promotion::LOCAL_DEAL
        redirect_to promotions_path, :alert => 'Merchants can only create local deals'
      end
      # Fall through to render 'new'
    else
      # Admins can only create ads/affiliates; check type argument
      # Sales admins can create local deals, too; fall through and render new
      @promotion.promotion_type = params[:promotion_type]
      if Promotion::AD == params[:promotion_type] or Promotion::AFFILIATE == params[:promotion_type]
        render 'new_ad', :layout => 'layouts/admin' and return
      elsif !current_user.has_role?(Role::SALES_ADMIN)
        redirect_to promotions_path, :alert => 'Can only create ads and affiliate promotions'
      end
    end 
    
    if admin_user?
      render :layout => 'layouts/admin'
    end
  end

  # GET /promotions/1/edit
  def edit
    # before_filter has already set @promotion
    # Don't order metros by name, or Pittsburgh won't be first
    @metros = Metro.all
    @categories = Category.order(:name)
    if admin_user?
      render :layout => 'layouts/admin'
    end
  end

  # POST /promotions
  def create
    # If created by a merchant, use the current_user's vendor
    # If created by an admin, the vendor id will come in the parameters
    if current_user.has_role?(Role::MERCHANT)
      vendor = current_user.vendor
      message = I18n.t('promotion_created')
    else
      vendor = Vendor.find(params[:promotion][:vendor_id])
      message = current_user.has_role?(Role::SALES_ADMIN) ? I18n.t('local_deal_created') : I18n.t('ad_created')
    end
    
    # This line ensures there is a category_id entry, and allows users to clear their selection
    params[:promotion][:category_ids] ||= []
    @promotion = vendor.promotions.build(params[:promotion])
    
    # Only deals have strategies; vouchers are not generated for affiliates/ads
    if @promotion.deal?
      # Get the promotion strategy from the hidden field (don't want to deal with nested polymorphic attributes; just assign it)
      @promotion.strategy = PromotionStrategyFactory.instance.create_promotion_strategy(params[:promotion_strategy], params)
    end
    
    # Only Local Deals need Machovy approved; others are coming in from Admins and are Edited by definition (so that they don't instantly go live)
    if Promotion::LOCAL_DEAL == @promotion.promotion_type 
      if current_user.has_role?(Role::SALES_ADMIN)
        @promotion.status = Promotion::EDITED
      end   
    else
      @promotion.status = Promotion::MACHOVY_APPROVED
    end
    
    if @promotion.save
      redirect_to @promotion, :notice => message
    else
      @metros = Metro.all
      @vendors = Vendor.order(:name)
      @categories = Category.order(:name)
      
      if Promotion::LOCAL_DEAL == @promotion.promotion_type
        # Ensure we show a slideshow image on edit
        @promotion.promotion_images.build
        render 'new', :layout => admin_user? ? 'layouts/admin' : 'layouts/application'
      else
        render 'new_ad', :layout => 'layouts/admin'
      end
    end
  end

  # PUT /promotions/1
  def update
    @promotion = Promotion.find(params[:id])
    # This line ensures there is a category_id entry, and allows users to clear their selection
    params[:promotion][:category_ids] ||= []
    
    # Convert to start_date, end_date properties so that the diff will detect them
    # Still won't find derivative things like the fixed promotion strategy dates.
    #   Could address that by showing missing keys, but that would also show spurious "changes" in array variables (e.g., categories)
    params[:promotion][:start_date] = DateTime.new(params[:promotion]['start_date(1i)'].to_i, params[:promotion]['start_date(2i)'].to_i, params[:promotion]['start_date(3i)'].to_i).utc
    params[:promotion][:end_date] = DateTime.new(params[:promotion]['end_date(1i)'].to_i, params[:promotion]['end_date(2i)'].to_i, params[:promotion]['end_date(3i)'].to_i).utc
    
    changes = Utilities::type_insensitive_diff(params[:promotion], @promotion.attributes)
    
    change_description = changes.empty? ? 'No changes' : changes.to_s    
    comment = "Edited by #{current_user.email}\n#{change_description}"
    vendor_action = current_user.has_role?(Role::MERCHANT)
    
    if vendor_action
      # If merchants are updating it, it was MACHOVY_REJECTED, and editing it makes it proposed again
      # If they didn't change anything, don't change the status
      if !changes.empty?
        params[:promotion][:status] = Promotion::PROPOSED
      end      
    else
      # If admins are updating it, have to look at the accept/reject, etc. logic
      # If editing an affiliate, there will not be a decision
      if params[:decision]
        case params[:decision]
          when 'accept'
            params[:promotion][:status] = Promotion::MACHOVY_APPROVED
          when 'reject'
            params[:promotion][:status] = Promotion::MACHOVY_REJECTED
          when 'edit'
            params[:promotion][:status] = Promotion::EDITED
          else
            raise RangeException, "Unknown decision: #{params[:decision]}" 
        end
      end
      
      comment = params[:comment] + "\n#{comment}" if params[:comment]
    end
    
    if @promotion.update_attributes(params[:promotion])
      @promotion.promotion_logs.create(:status => params[:promotion][:status], 
                                       :comment => comment)  
      # Send email only on admin actions on local deals
      if !vendor_action and @promotion.deal?
        VendorMailer.delay.promotion_status_email(@promotion)
      end 
      
      redirect_to promotions_path, notice: I18n.t('promotion_updated')
    else
      @metros = Metro.all
      @categories = Category.order(:name)
      render 'edit', :layout => admin_user? ? 'layouts/admin' : 'layouts/application'  
    end    
  end

  # DELETE /promotions/1
  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy

    redirect_to promotions_path
  end
  
  def manage
    # Without default scope, need to explicitly order by weight
    @promotions = Promotion.order(:grid_weight).paginate(:page => params[:page])
    @weights = Promotion.order(:grid_weight).map { |p| p.grid_weight }
    @diff = @weights[@weights.length - 1] - @weights[0]
    # Large step
    @page_value = [1, @diff / 10].max.roundup
    # Small step
    @step_value = @page_value / 10
    
    # Don't want default application layout, with footer, etc.
    render :layout => 'layouts/admin'
  end
  
  def affiliates
    @affiliates = Promotion.affiliates.order(:grid_weight).paginate(:page => params[:page])
    render :layout => 'layouts/admin'
  end
  
  # Called from front page manager with Ajax
  def update_weight
    @promotion = Promotion.find(params[:id])
    old_weight = @promotion.grid_weight
    
    respond_to do |format|
      format.js do
        if @promotion.update_attributes(params[:promotion])
          head :ok
        else
          render :js => "alert('Weight update failed'); $('#grid_weight_#{params[:id]}').val(#{old_weight})"
        end
      end
    end
  end
  
  def rebalance
    algorithm = WeightingFactory.instance.create_weighting_algorithm
    
    promotion_weights = WeightingFactory.instance.create_weight_data(Promotion.name)
    Promotion.all.each { |promotion| promotion_weights.add(promotion) }
    algorithm.reweight(promotion_weights)
    Promotion.all.each { |promotion| logger.info(promotion_weights.save(promotion)) }    
    
    redirect_to manage_promotions_path, :notice => 'Recalculated promotion weights'
  end
  
private
  HORNDOGS = ['jeff@machovy.com', 'adanaie@gmail.com']
  
  # Need to check for displayable, since we're also showing "zombie" deals that have sold out
  def eligible_to_purchase(promotion)
    promotion.displayable? && 
    (current_user.nil? ||
      (current_user.is_customer? && 
        (HORNDOGS.include?(current_user.email) ||
        # Make sure this particular user hasn't exhausted the max_per_customer
        ((promotion.max_quantity_for_buyer(current_user) > 0) &&
          # ALSO make sure this user has enough available to satisfy the *minimum* as well
          #   For instance, it's min 2, max 3. They bought 2 already, and only have 1 left
          #   Pathological case, but possible unless we explicitly prevent it with very complex logic
          (promotion.min_per_customer <= promotion.max_quantity_for_buyer(current_user)))
        )
      )
    )
  end
  
  def validate_eligible
    @promotion = Promotion.find(params[:id])
    if !eligible_to_purchase(@promotion)
      redirect_to promotion_path(@promotion), :alert => I18n.t('nice_try')
    end
  end
  
  # Devise/CanCan has already ensured there's a logged in user with appropriate permissions
  # We additionally need to make sure it's a vendor (or SuperAdmin)
  def ensure_vendor
    if !admin_user?
      if current_user.vendor.nil?
        redirect_to root_path, :alert => I18n.t('vendors_only') 
      end
    end
  end

  def ensure_vendor_or_super_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      if current_user.vendor.nil?
        redirect_to root_path, :alert => I18n.t('vendors_only') 
      end
    end
  end
  
  def ensure_correct_vendor
    if !admin_user?
      @promotion = Promotion.find(params[:id])
      if @promotion.vendor != current_user.vendor
        redirect_to root_path, :alert => I18n.t('foreign_promotion')
      end
    end
  end
    
  def admin_only
    unless admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end      
  end  
  
  def transform_prices
    if !params[:promotion].nil? 
      params[:promotion][:retail_value].gsub!('$', '') unless params[:promotion][:retail_value].nil?
      params[:promotion][:price].gsub!('$', '') unless params[:promotion][:price].nil?
    end    
  end
end
