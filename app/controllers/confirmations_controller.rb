class ConfirmationsController < Devise::ConfirmationsController
    
  def show
    with_unconfirmed_confirmable do
      if @confirmable.vendor.nil?
        # If a regular user, sign in and confirm
        super
      else
        # If a vendor
        @confirmable.confirm!
        set_flash_message :notice, :confirmed_vendor
        
        @confirmable.roles << Role.find_by_name(Role::MERCHANT)
        
        VendorMailer.signup_email(@confirmable.vendor).deliver
        
        sign_in_and_redirect(resource_name, @confirmable)
      end
    end

    if !@confirmable.errors.empty?
      self.resource = @confirmable
      render 'devise/confirmations/new' #Change this if you don't have the views on default path 
    end
  end
  
protected
  def with_unconfirmed_confirmable
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    if !@confirmable.new_record?
      @confirmable.only_if_unconfirmed {yield}
    end
  end
end