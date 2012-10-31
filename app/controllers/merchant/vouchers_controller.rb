class Merchant::VouchersController < Merchant::BaseController
  respond_to :html, :js, :png
  
  before_filter :authenticate_user!, :except => [:generate_qrcode]
  before_filter :ensure_correct_vendor, :only => [:redeem]
  
  load_and_authorize_resource
  
  # GET /vouchers
  def index
    # If a voucher_id or a user_id is given, it's coming from a search request
    @display_controls = false
    @display_search = false
    if params[:voucher_id] or params[:user_id] or params[:promotion_id]
      if current_user.has_role?(Role::MERCHANT)
        @display_controls = true
        if params[:voucher_id]
          @vouchers = [Voucher.find(params[:voucher_id])].paginate(page: params[:page])
        elsif params[:user_id]
          @vouchers = User.find(params[:user_id]).vouchers.paginate(page: params[:page])
        else
          @display_search = true
          @vouchers = Promotion.find(params[:promotion_id]).vouchers.paginate(page: params[:page])
        end
      else
        redirect_to root_path, :alert => I18n.t('vendors_only')
      end
    else      
      # It's a user asking for their own vouchers
      @vouchers = current_user.vouchers.paginate(page: params[:page])
    end    
  end

  # GET /vouchers/1
  def show
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      format.png { render :qrcode =>  redeem_merchant_voucher_url(@voucher) }
    end
  end

  def generate_qrcode
    @voucher = Voucher.find(params[:id])
    
    respond_to do |format|
      format.png { render :qrcode => redeem_merchant_voucher_url(@voucher) }
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
  
  # GET /vouchers/1/redeem
  def redeem
    @voucher = Voucher.find(params[:id])
    @voucher.status = params[:status]
    if Voucher::REDEEMED == params[:status]
      @voucher.redemption_date = Time.now
    else
      # Unusual if another status, so record
      @voucher.notes += "\nStatus changed to #{params[:status]} on #{Time.now.try(:strftime, '%b %d, %Y')}"
    end
    
    if @voucher.save
      flash[:notice] = I18n.t('voucher_success')
    else
      flash[:alert] = I18n.t('voucher_failure')
    end
    
    @vouchers = Promotion.find(params[:promotion_id]).vouchers
    @display_controls = true
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
