class VendorMailer < ActionMailer::Base
  PROMOTION_STATUS_MESSAGE = 'Action on your Machovy promotion'

  default from: ApplicationHelper::MAILER_FROM_ADDRESS
  
  def promotion_status_email(promotion)
    @promotion = promotion
    
    if [Promotion::EDITED, Promotion::MACHOVY_APPROVED, Promotion::MACHOVY_REJECTED].include?(@promotion.status)
      mail(:to => promotion.vendor.user.email, :subject => PROMOTION_STATUS_MESSAGE) 
    else
      # Should never happen
      raise "Invalid status for email"
    end
  end
end
