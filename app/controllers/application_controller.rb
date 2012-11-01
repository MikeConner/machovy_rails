class ApplicationController < ActionController::Base
  protect_from_forgery

  # Redirect on signup based on role
  def after_sign_in_path_for(resource)
    path = resource.has_role?(Role::MERCHANT) ? promotions_path : root_path
    (session[:"user.return_to"].nil?) ? path : session[:"user.return_to"].to_s
  end 
    
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => I18n.t('admins_only')
  end  
end
