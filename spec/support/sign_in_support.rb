# module for helping request specs
module ValidUserRequestHelper
  # for use in request specs
  def sign_in_as_a_valid_user
    @user ||= FactoryGirl.create :user
    post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end
  
  def sign_in_as_a_vendor
    @user ||= FactoryGirl.create :user
    @vendor = FactoryGirl.create(:vendor, :user => @user)
    @user.roles << Role.find_by_name(Role::MERCHANT)
  end
end

# Unused first attempts :-)
# include in spec_helper to use
=begin
module ValidUserHelper
  def signed_in_as_a_valid_user
    @user ||= FactoryGirl.create :user
    sign_in @user # method from devise:TestHelpers
  end
end

module RequestMacros
  include Warden::Test::Helpers

  # for use in request specs
  def sign_in_as_a_user
    @user ||= FactoryGirl.create :confirmed_user
    login_as @user
  end
end
=end