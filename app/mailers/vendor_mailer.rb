class VendorMailer < ActionMailer::Base  
  PROMOTION_STATUS_MESSAGE = 'Action on your Machovy promotion'
  SIGNUP_MESSAGE = 'Welcome to Machovy!'
  LEGAL_AGREEMENT_FILENAME = 'MachovyAgreement1b.pdf'
  LEGAL_AGREEMENT_HTML = 'MerchantAgreement.htm'
  PAYMENT_MESSAGE = "Your check from Machovy is in the mail"
  
  default from: ApplicationHelper::MAILER_FROM_ADDRESS
  
  def promotion_status_email(promotion)
    @promotion = promotion
    
    if [Promotion::EDITED, Promotion::MACHOVY_APPROVED, Promotion::MACHOVY_REJECTED].include?(@promotion.status)
      # For things like coupons and ads, there may not be a user
      if promotion.vendor.user.nil?
        mail(:to => ApplicationHelper::MACHOVY_SALES_ADMIN, :subject => PROMOTION_STATUS_MESSAGE)        
      else
        mail(:to => promotion.vendor.user.email, :subject => PROMOTION_STATUS_MESSAGE)
      end
    else
      # Should never happen
      raise "Invalid status for email"
    end
  end
  
  def signup_email(vendor)
    @vendor = vendor
    
    #attachments['VendorAgreement.pdf'] = File.read(MachovyRails::Application.assets.find_asset(LEGAL_AGREEMENT_FILENAME).pathname)
    mail(:to => vendor.user.email, :bcc => ApplicationHelper::MACHOVY_MERCHANT_ADMIN, :subject => SIGNUP_MESSAGE)
  end
  
  def payment_email(vendor, payment)
    @vendor = vendor
    @payment = payment
    
    mail(:to => vendor.user.email, :bcc => ApplicationHelper::MACHOVY_MERCHANT_ADMIN, :subject => PAYMENT_MESSAGE)
  end
end
