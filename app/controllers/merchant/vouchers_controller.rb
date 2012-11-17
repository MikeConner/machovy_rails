class Merchant::VouchersController < Merchant::BaseController
  respond_to :html, :js, :png
  
  before_filter :authenticate_user!, :except => [:generate_qrcode]
  before_filter :ensure_correct_vendor, :only => [:redeem, :redeem_admin]
  
  load_and_authorize_resource
  
  # GET /vouchers
  def index
    if current_user.has_role?(Role::MERCHANT)
      @title = 'Voucher Administration'
      @admin = true
      
      # If a voucher_id or a user_id is given, it's coming from a search request
      if params[:voucher_id]
        @vouchers = [Voucher.find(params[:voucher_id])]
      elsif params[:user_id]
        @vouchers = User.find(params[:user_id]).vouchers
      else
        @vouchers = []
      end
    else
      # It's a user asking for their own vouchers
      @title = 'Listing Vouchers'
      @admin = false
      @vouchers = current_user.vouchers
    end
  end

  # GET /vouchers/1
  def show
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      format.png { render :qrcode =>  redeem_merchant_voucher_url(@voucher, :subdomain => ApplicationHelper::REDEMPTION_SUBDOMAIN) }
    end
  end

  def generate_qrcode
    @voucher = Voucher.find(params[:id])
    
    respond_to do |format|
      format.png { render :qrcode => redeem_merchant_voucher_url(@voucher, :subdomain => ApplicationHelper::REDEMPTION_SUBDOMAIN) }
      format.html { render :nothing => true }
    end
  end
  
  def search
    voucher = Voucher.find_by_uuid(params[:key])
    if voucher.nil?
      user = User.find_by_email(params[:key])
    end
        
    respond_to do |format|
      format.js do
        if voucher.nil? and user.nil?
          render :json => "none".to_json
        else
          if user.nil?
            render :js => "window.location.href = \"#{merchant_vouchers_path(:voucher_id => voucher.id)}\""
          else
            render :js => "window.location.href = \"#{merchant_vouchers_path(:user_id => user.id)}\""
          end
        end 
      end
    end    
  end
  
  # Redeem from a QR code (e.g., doorman)
  # GET /vouchers/1/redeem
  def redeem
    # @voucher set from the filter
    case @voucher.status
    when Voucher::REDEEMED
      flash[:alert] = I18n.t('voucher_already_redeemed')
    when Voucher::RETURNED
      flash[:alert] = I18n.t('voucher_returned')
    when Voucher::EXPIRED
      flash[:alert] = I18n.t('voucher_expired')
    when Voucher::AVAILABLE
      flash[:notice] = I18n.t('voucher_valid')
    else
      raise 'Unknown voucher status'
    end
    
    @vouchers = [@voucher]
    @admin = true

    render 'index'
  end
  
  # Redeem (or Unredeem/Return) from the merchant admin interface
  # PUT /vouchers/1/redeem_admin
  def redeem_admin
    # @voucher set from the filter
    @voucher.status = params[:status]
    if Voucher::REDEEMED == params[:status]
      @voucher.redemption_date = Time.now
    else
      # Unusual if another status, so record
      @voucher.notes += "\nStatus changed to #{params[:status]} on #{Time.now.try(:strftime, '%b %d, %Y')}"
    end
    
    if @voucher.save
      flash[:notice] = I18n.t('voucher_success')
      
      # Send survey on redemption, and a notice on unredemption (saying they can still use the voucher)
      # Do nothing on return; presumably the customer has handed it in
      if Voucher::REDEEMED == @voucher.status
        UserMailer.survey_email(@voucher.order).deliver
      elsif Voucher::AVAILABLE == @voucher.status
        UserMailer.unredeem_email(@voucher).deliver
      end
    else
      flash[:alert] = I18n.t('voucher_failure')
    end
    
    @title = 'Voucher Administration'
    @admin = true
    @vouchers = []
    
    render 'index'
  end

  # Unused / Leftover scaffolding
=begin
  # GET /vouchers/1/edit
  def edit
    @voucher = Voucher.find(params[:id])
  end
  
  # GET /vouchers/new
  def new
    @voucher = Voucher.new
  end
  
  # POST /vouchers
  def create
    @voucher = Voucher.new(params[:voucher])
   if @voucher.save
     redirect_to @voucher, notice: 'Voucher was successfully created.'
   else
     render 'new'
   end
  end

  # PUT /vouchers/1
  def update
    @voucher = Voucher.find(params[:id])
    if @voucher.update_attributes(params[:voucher])
      redirect_to @voucher, notice: 'Voucher was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /vouchers/1
  def destroy
    @voucher = Voucher.find(params[:id])
    @voucher.destroy

    redirect_to vouchers_path
  end  
=end  
  
private
  def ensure_correct_vendor
    if !current_user.has_role?(Role::SUPER_ADMIN)
      @voucher = Voucher.find(params[:id])
      if @voucher.promotion.vendor != current_user.vendor
        redirect_to root_path, :alert => I18n.t('foreign_voucher')
      end
    end
  end
end
