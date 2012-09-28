module ApplicationHelper
  def admin_user?
    user_signed_in? && current_user.super_admin?
  end
end
