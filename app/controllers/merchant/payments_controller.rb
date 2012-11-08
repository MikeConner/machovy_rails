class Merchant::PaymentsController < Merchant::BaseController
  before_filter :authenticate_user!
  before_filter :super_admin_user
  
  def new
    init_vouchers(params[:vendor_id])
    
    @payment = @vendor.payments.build(:amount => @vendor.amount_owed, :check_date => Time.now.beginning_of_day)
  end
  
  def create
    @payment = Payment.new(params[:payment])
    init_vouchers(@payment.vendor_id)

    if @payment.save
      excluded_vouchers = JSON.parse(params['excluded_vouchers'])
      # Mark the vouchers as paid
      @unpaid_vouchers.each do |voucher|
        if !excluded_vouchers.include?(voucher.id.to_s)
          voucher.payment_id = @payment.id
          if !voucher.save
            logger.error "Could not save voucher #{voucher.id}"
          end
        end
      end
      
      VendorMailer.payment_email(@vendor, @payment).deliver
      
      redirect_to show_payments_merchant_vendor_path(@vendor), notice: I18n.t('payment_processed')
    else
      render 'new'
    end    
  end
  
private
  def init_vouchers(vendor_id)
    @vendor = Vendor.find(vendor_id)
    @unpaid_vouchers = []
    @vendor.orders.each do |order|
      order.vouchers.each do |voucher|
        if voucher.payment_owed?
          @unpaid_vouchers.push(voucher)
        end
      end
    end    
  end
  
  def super_admin_user
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end