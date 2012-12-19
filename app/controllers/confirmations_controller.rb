# Override devise in order to handle special processing related to vendors  
#
class ConfirmationsController < Devise::ConfirmationsController
  def show
    with_unconfirmed_confirmable do
      if @confirmable.vendor.nil?
        # If a regular user, sign in and confirm
        super
        
        # Are there any GiftCertificates for this user?
        # If a regular signup, will be in email; if they're changing their email *to* a target, it will be in unconfirmed_email
        @certificates = GiftCertificate.pending.where('email = ? or email = ?', @confirmable.email, @confirmable.unconfirmed_email)
        @certificates.each do |certificate|
          ActiveRecord::Base.transaction do
            @confirmable.macho_bucks.create!(:amount => certificate.amount, :notes => "Gift certificate bought by #{certificate.user.email}")
            # reset pending flag
            certificate.pending = false
            certificate.save!

            # Mail to giver saying that their macho bucks recipient has signed up and was credited
            UserMailer.delay.gift_redeemed_email(certificate)
            # Mail to recipient saying that their macho bucks are available
            UserMailer.delay.gift_credited_email(certificate)
          end
        end
      else
        # If a vendor
        @confirmable.confirm!
        set_flash_message :notice, :confirmed_vendor
        
        @confirmable.roles << Role.find_by_name(Role::MERCHANT)
        
        VendorMailer.delay.signup_email(@confirmable.vendor)
        
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