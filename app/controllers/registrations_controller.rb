require 'phone_utils'

class RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper
  
  # Note -- very similar filters are in vendors_controller (can't share because arguments are different)
  before_filter :transform_phones, only: [:create, :update]
  before_filter :upcase_state, only: [:create, :update]
  
  def new
    super
  end
  
  def create
    # Detect merchant so that it displays the right fields in case of errors
    @is_merchant = params[:user][:vendor_attributes]
    # Kind of hacky, but it's complicated because all sign in and regular user sign up are on one page, 
    #   and vendor signup is on another page
    @user = User.new(params[:user])
    
    if @user.save      
      redirect_to root_path, :notice => I18n.t('devise.registrations.signed_up_but_unconfirmed')
    else
      if @is_merchant
        # There could be vendor field errors, so we need to copy them from the @user object instead of overwriting
        flash[:alert] = ''
        
        @user.errors.full_messages.each do |msg|
          flash[:alert] << msg + "\n"
        end
      
        render 'new'
      else
        redirect_to new_user_session_path, :alert => I18n.t('devise.failure.invalid')
      end
    end
  end

private
  def upcase_state
    if !params[:user].nil? and !params[:user][:vendor_attributes].nil?
      if !params[:user][:vendor_attributes][:state].blank?
        params[:user][:vendor_attributes][:state].upcase!
      end
    end
  end
  
  def transform_phones
    # if you do a put with the wrong user (e.g., an attack), these won't be defined
    if !params[:user].nil? and !params[:user][:vendor_attributes].nil?
      phone_number = params[:user][:vendor_attributes][:phone]
      if !phone_number.blank? and (phone_number !~ /#{ApplicationHelper::US_PHONE_REGEX}/)
        params[:user][:vendor_attributes][:phone] = PhoneUtils::normalize_phone(phone_number)
      end       
    end
  end
end 