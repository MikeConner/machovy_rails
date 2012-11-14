require 'phone_utils'

class Merchant::VendorsController < Merchant::BaseController
  include ApplicationHelper
  
  before_filter :authenticate_user!
  # Note -- very similar filters are in registrations_controller (can't share because arguments are different)
  before_filter :transform_phones, only: [:create, :update]
  before_filter :upcase_state, only: [:create, :update]
  before_filter :ensure_correct_vendor, :only => [:reports, :show_payments]
  before_filter :admin_user, :except => [:reports, :show_payments]
  
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
  
  def show_payments
    # Logic goes in the controller -- too much to do in a view
    @payment_data = []
    @vendor.promotions.each do |promotion|
      detail = Hash.new
      @payment_data.push(detail)
      detail[:title] = promotion.title
      detail[:sold] = promotion.vouchers.count
      detail[:returned] = 0
      detail[:redeemed] = 0
      detail[:total] = 0
      detail[:merchant_share] = 0
      promotion.vouchers.each do |voucher|
        if voucher.status == Voucher::RETURNED
          detail[:returned] += 1
        elsif voucher.status == Voucher::REDEEMED
          detail[:redeemed] += 1
          detail[:total] += voucher.order.total_cost
          detail[:merchant_share] += voucher.order.merchant_share
        end
      end
    end
    
    if admin_user?
      render :layout => 'layouts/admin'
    end
  end

  # GET /vendors
  def index
    render :layout => 'layouts/admin'
  end

  # GET /vendors/1
  def show
    @vendor = Vendor.find(params[:id])
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
    render :layout => 'layouts/admin'
  end

  # GET /vendors/1/edit
  def edit
    @vendor = Vendor.find(params[:id])
    render :layout => 'layouts/admin'
  end

  # POST /vendors
  def create
    @vendor = Vendor.new(params[:vendor])
    if @vendor.save
      redirect_to [:merchant, @vendor], notice: I18n.t('vendor_created')
    else
      render 'new', :layout => 'layouts/admin'
    end
  end

  # PUT /vendors/1
  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update_attributes(params[:vendor])
      redirect_to show_payments_merchant_vendor_path(@vendor), notice: 'Vendor was successfully updated.'
    else
      render 'edit', :layout => 'layouts/admin'
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
  
  def admin_user
    if !admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
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
