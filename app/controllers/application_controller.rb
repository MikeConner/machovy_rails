class ApplicationController < ActionController::Base
  protect_from_forgery

  # Redirect on signup based on role
  def after_sign_in_path_for(resource)
    # User-selected metros (or those selected when not logged in) should not survive login
    session[:metro_selected] = nil
    if resource.has_role?(Role::MERCHANT) 
      if trying_to_redeem_voucher
        session[:user_return_to]
      else
        promotions_path
      end
    else
      session[:user_return_to].nil? ? root_path : session[:user_return_to]
    end
  end 

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => I18n.t('admins_only')
  end  
  
private
  def trying_to_redeem_voucher
    !session[:user_return_to].nil? && session[:user_return_to] =~ /merchant\/vouchers\/.*?\/redeem$/i
  end
end
