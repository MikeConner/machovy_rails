class Merchant::VouchersController < Merchant::BaseController
  respond_to :html, :js, :png
  
  before_filter :authenticate_user!, :except => [:generate_qrcode]
  before_filter :ensure_correct_vendor, :only => [:redeem, :redeem_admin]
  
  load_and_authorize_resource
  
  # GET /vouchers
  def index
    if current_user.is_customer?
      # It's a user asking for their own vouchers
      @vouchers = current_user.vouchers      
    elsif current_user.has_role?(Role::MERCHANT) or current_user.has_role?(Role::SUPER_ADMIN)
      # If a voucher_id or a user_id is given, it's coming from a search request
      if params[:voucher_id]
        @vouchers = [Voucher.find(params[:voucher_id])]
      elsif params[:user_id]
        @vouchers = User.find(params[:user_id]).vouchers
      else
        @vouchers = []
      end
    end
    
    # Calculate gift certificates that they have given
    @pending_gifts = GiftCertificate.pending.where('user_id = ?', current_user.id)
    @redeemed_gifts = GiftCertificate.redeemed.where('user_id = ?', current_user.id)
    
    if current_user.has_role?(Role::SUPER_ADMIN)
      render :layout => 'layouts/admin'
    end
  end

  # GET /vouchers/1
  def show
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      format.png { render :qrcode => redeem_merchant_voucher_url(@voucher) }
    end
  end

  def generate_qrcode
    @voucher = Voucher.find(params[:id])
    
    respond_to do |format|
      format.png { render :qrcode => redeem_merchant_voucher_url(@voucher) }
      format.html { render :nothing => true }
    end
  end
  
  def printable_qrcode
    @voucher = Voucher.find(params[:id])
    render :layout => false
  end
  
  def search
    user = User.find_by_email(params[:key])
    if user.nil?
      voucher = Voucher.find_by_uuid(normalize_uuid(params[:key]))
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
        UserMailer.delay.survey_email(@voucher.order)
      elsif Voucher::AVAILABLE == @voucher.status
        UserMailer.delay.unredeem_email(@voucher)
      elsif Voucher::RETURNED == @voucher.status
        # Credit Macho Bucks
        bucks = @voucher.build_macho_buck(:user_id => @voucher.order.user.id, :amount => @voucher.order.amount, :notes => params[:notes])
        if !bucks.save
          flash[:alert] = 'Unable to credit macho bucks!'
        end
        UserMailer.delay.macho_bucks_voucher_email(bucks)
      end
    else
      flash[:alert] = I18n.t('voucher_failure')
    end
    
    @vouchers = []
    
    render 'index'
  end
  
private
  def ensure_correct_vendor
    if !current_user.has_role?(Role::SUPER_ADMIN)
      @voucher = Voucher.find(params[:id])
      if @voucher.promotion.vendor != current_user.vendor
        redirect_to root_path, :alert => I18n.t('foreign_voucher')
      end
    end
  end
  
  # tolerate missing dashes, mixed case, etc.
  def normalize_uuid(key)
    norm_key = key.downcase.gsub(/[-\s]/, '')
    if 10 == norm_key.length
      "#{norm_key[0..2]}-#{norm_key[3..5]}-#{norm_key[6..9]}"
    else
      key
    end
  end
end
