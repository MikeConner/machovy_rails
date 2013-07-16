class Merchant::BitcoinInvoicesController < Merchant::BaseController
  before_filter :authenticate_user!
  before_filter :super_admin_user

  def show
    @invoice = BitcoinInvoice.find(params[:id])
    @last_update = @invoice.invoice_status_updates.empty? ? invoice.created_at : @invoice.invoice_status_updates.order('updated_at DESC').first.created_at
  end
  
private
  def super_admin_user
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end