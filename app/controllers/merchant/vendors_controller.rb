require 'phone_utils'

class Merchant::VendorsController < Merchant::BaseController
  before_filter :authenticate_user!
  # Note -- very similar filters are in registrations_controller (can't share because arguments are different)
  before_filter :transform_phones, only: [:create, :update]
  before_filter :upcase_state, only: [:create, :update]
  before_filter :ensure_correct_vendor, :only => [:reports]

  load_and_authorize_resource
  
  def reports
    # Already have the @vendor instance from the filter
    # Create data table for the view - no complex calculations in the view! 
    #   Also, generalize over status so that it will continue to work even if statuses are added/changed
    @report_title = "Promotion status report for #{@vendor.name}"

    @table_data = []
    @vendor.promotions.each do |promotion|
      p_data = Hash.new
      @table_data.push(p_data)
      p_data[:promotion] = promotion
      # status -> count
      voucher_data = Hash.new
      promotion.vouchers.each do |voucher|
        if voucher_data.has_key?(voucher.status)
          voucher_data[voucher.status] += 1
        else
          voucher_data[voucher.status] = 1
        end
      end
      p_data[:vouchers] = voucher_data
    end
  end

  def payments
  end

  def dashboard
    @vendor = current_user.vendor
    if !@vendor.nil?
        @promotion = @vendor.promotions.find(params[:id])
        @vouchers = @vendor.promotions.find(params[:id]).vouchers
    end
  end
  
  # GET /vendors
  def index
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
    @vendor = Vendor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vendor }
    end
  end

  # GET /vendors/new
  # GET /vendors/new.json
  def new
    @vendor = Vendor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vendor }
    end
  end

  # GET /vendors/1/edit
  def edit
    @vendor = Vendor.find(params[:id])
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(params[:vendor])
    if @vendor.save
      redirect_to [:merchant, @vendor], notice: I18n.t('vendor_created')
    else
      render 'new'
    end
  end

  # PUT /vendors/1
  # PUT /vendors/1.json
  def update
    @vendor = Vendor.find(params[:id])

    respond_to do |format|
      if @vendor.update_attributes(params[:vendor])
        format.html { redirect_to @vendor, notice: 'Vendor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy

    respond_to do |format|
      format.html { redirect_to vendors_url }
      format.json { head :no_content }
    end
  end
  
private
  def ensure_correct_vendor
    if !current_user.has_role?(Role::SUPER_ADMIN)
      @vendor = Vendor.find(params[:id])
      if @vendor != current_user.vendor
        redirect_to root_path, :alert => I18n.t('foreign_vendor')
      end
    end
  end
  
  def upcase_state
    if !params[:vendor].nil?
      if !params[:vendor][:state].blank?
        params[:vendor][:state].upcase!
      end
    end
  end
  
  def transform_phones
    if !params[:vendor].nil?
      phone_number = params[:vendor][:phone]
      if !phone_number.blank? and (phone_number !~ /#{ApplicationHelper::US_PHONE_REGEX}/)
        params[:vendor][:phone] = PhoneUtils::normalize_phone(phone_number)
      end       
    end
  end
end
