require 'phone_utils'

class RegistrationsController < Devise::RegistrationsController
  # Note -- very similar filters are in vendors_controller (can't share because arguments are different)
  before_filter :transform_phones, only: [:create, :update]
  before_filter :upcase_state, only: [:create, :update]
  
  def new
    # I would rather make a new view than edit the standard devise one, but I still want the default 
    #   controller definitions and behavior, and the controller logic seems to be hidden in the gem!
    # So set this to trigger adding the additional fields in the view
    @is_merchant = params[:merchant]
    @signup_message = @is_merchant ? "Merchant Sign up" : "Sign up"
    super
  end

  def create
    # Detect merchant so that it displays the right fields in case of errors
    @is_merchant = params[:user][:vendor_attributes]
    super
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