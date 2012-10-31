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

  # GET /vendors
  def index
  end

  # GET /vendors/1
  def show
    @vendor = Vendor.find(params[:id])
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
  end

  # GET /vendors/1/edit
  def edit
    @vendor = Vendor.find(params[:id])
  end

  # POST /vendors
  def create
    @vendor = Vendor.new(params[:vendor])
    if @vendor.save
      redirect_to [:merchant, @vendor], notice: I18n.t('vendor_created')
    else
      render 'new'
    end
  end

  # PUT /vendors/1
  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update_attributes(params[:vendor])
      redirect_to [:merchant, @vendor], notice: 'Vendor was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /vendors/1
  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy

    redirect_to vendors_path
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
