class Merchant::VouchersController < Merchant::BaseController
  before_filter :authenticate_user!
  before_filter :ensure_correct_vendor, :only => [:redeem]
  load_and_authorize_resource
  
  # GET /vouchers
  def index
    # If called with a promotion_id, it's a merchant, and we want
    @display_controls = false
    if params[:promotion_id]
      # verify once again that it's a vendor -- otherwise security risk!
      if current_user.has_role?(Role::MERCHANT)
        @vouchers = Promotion.find(params[:promotion_id]).vouchers
        @display_controls = true
      else
        redirect_to root_path, :alert => I18n.t('vendors_only')
      end
    else
      @vouchers = current_user.vouchers.all
    end
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @voucher }
      format.png { render :qrcode =>  redeem_merchant_voucher_url(@voucher) }
    end
  end

  # GET /vouchers/new
  # GET /vouchers/new.json
  def new
    @voucher = Voucher.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @voucher }
    end
  end

  # GET /vouchers/1/edit
  def edit
    @voucher = Voucher.find(params[:id])
  end
  
  def generate_qrcode
    @voucher = Voucher.find(params[:id])
    
    respond_to do |format|
      format.png { render :qrcode => redeem_merchant_voucher_url(@voucher) }
      format.html { render :nothing => true }
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

  # POST /vouchers
  # POST /vouchers.json
  def create
    @voucher = Voucher.new(params[:voucher])

    respond_to do |format|
      if @voucher.save
        format.html { redirect_to @voucher, notice: 'Voucher was successfully created.' }
        format.json { render json: @voucher, status: :created, location: @voucher }
      else
        format.html { render action: "new" }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /vouchers/1
  # PUT /vouchers/1.json
  def update
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      if @voucher.update_attributes(params[:voucher])
        format.html { redirect_to @voucher, notice: 'Voucher was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vouchers/1
  # DELETE /vouchers/1.json
  def destroy
    @voucher = Voucher.find(params[:id])
    @voucher.destroy

    respond_to do |format|
      format.html { redirect_to vouchers_url }
      format.json { head :no_content }
    end
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
end
