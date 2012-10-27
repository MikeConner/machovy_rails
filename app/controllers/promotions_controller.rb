require 'utilities'

class PromotionsController < ApplicationController
  respond_to :html, :js

  include ApplicationHelper
  
  before_filter :authenticate_user!, :except => [:show]
  # SuperAdmins and ContentAdmins can do these functions
  before_filter :ensure_vendor, :only => [:index, :new, :create]
  # Only SuperAdmins (and vendors) can edit local deals
  before_filter :ensure_vendor_or_super_admin, :only => [:edit]
  before_filter :ensure_correct_vendor, :only => [:edit, :show_logs, :accept_edits, :reject_edits]
  before_filter :admin_only, :only => [:manage]
  
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
          elsif promotion.awaiting_machovy_action?
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
      
      render 'index_admin' and return
    else
      redirect_to root_path, :alert => 'admins_only'
    end
  end

  # GET /promotions/1
  def show
    @promotion = Promotion.find(params[:id])
    # WARNING!
    # When assigning booleans, need to use ||, not OR operator. If you change to and/or it will break!
    @show_buy_button = current_user.nil? || current_user.is_customer? || current_user.has_role?(Role::SUPER_ADMIN)
    @show_terms = !current_user.nil? && !current_user.is_customer?
    @show_accept_reject = !current_user.nil? && current_user.has_role?(Role::MERCHANT) && @promotion.status == Promotion::EDITED
    
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
    @promotion = Promotion.find(params[:id])
    fine_print = @promotion.limitations.nil? && @promotion.voucher_instructions.nil? ? nil : 
                @promotion.limitations.to_s + "\n" + @promotion.voucher_instructions.to_s
    @order = @promotion.orders.build(:user_id => current_user.id, :email => current_user.email, :amount => @promotion.price, 
                                     :description => "#{@promotion.vendor.name} promo #{@promotion.title} #{Date.today.to_s}",
                                     :fine_print => fine_print)
    # Pass in stripe Customer object if there is one
    @stripe_customer = current_user.stripe_customer_obj
  end

  # GET /promotions/new
  def new
    @promotion = Promotion.new
    # Merchants should render default "new"
    if current_user.has_role?(Role::MERCHANT)
      # For now, merchants can only create local deals
      # If they can create ads later, just redirect to new_ad instead
      if params[:promotion_type] != Promotion::LOCAL_DEAL
        redirect_to :back, :alert => 'Merchants can only create local deals'
      end
      # Required to support nested attributes
      @promotion.promotion_images.new
      # Fall through to render 'new'
    else
      # Admins can only create ads/affiliates; check type argument
      if params[:promotion_type] == Promotion::AD or params[:promotion_type] == Promotion::AFFILIATE
        @promotion.promotion_type = params[:promotion_type]
        render 'new_ad' and return
      else
        redirect_to :back, :alert => 'Can only create ads and affiliate promotions'
      end
    end
  end

  # GET /promotions/1/edit
  def edit
    # before_filter has already set @promotion
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
      message = I18n.t('ad_created')
    end
    
    @promotion = vendor.promotions.build(params[:promotion])
    # Only Local Deals need Machovy approved; others are coming in from Admins and are Approved by definition
    if @promotion.promotion_type != Promotion::LOCAL_DEAL
      @promotion.status = Promotion::MACHOVY_APPROVED
    end
    
    if @promotion.save
      redirect_to @promotion, :notice => message
    else
      if current_user.has_role?(Role::MERCHANT)
        render 'new'
      else
        render 'new_ad'
      end
    end
  end

  # PUT /promotions/1
  def update
    @promotion = Promotion.find(params[:id])
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
      
      comment = params[:comment] + "\n#{comment}"
    end
    
    if @promotion.update_attributes(params[:promotion])
      @promotion.promotion_logs.create(:status => params[:promotion][:status], 
                                       :comment => comment)  
      # Send email on admin actions only   
      if !vendor_action
        VendorMailer.promotion_status_email(@promotion).deliver
      end 
      
      redirect_to @promotion, notice: I18n.t('promotion_updated')
    else
      render 'edit'  
    end    
  end

  # DELETE /promotions/1
  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy

    respond_to do |format|
      format.html { redirect_to promotions_url }
      format.json { head :no_content }
    end
  end
  
  def manage
    @promotions = Promotion.all
    
    # Don't want default application layout, with footer, etc.
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
  
private
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
end
