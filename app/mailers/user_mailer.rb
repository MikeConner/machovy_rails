class UserMailer < ActionMailer::Base
  helper :application
  
  ORDER_MESSAGE = 'Thank you for your Machovy promotion order'
  SURVEY_MESSAGE = 'Thanks for redeeming your voucher'
  UNREDEEM_MESSAGE = 'Your Machovy voucher is available for use'
  MACHO_CREDIT_MESSAGE = 'Macho Bucks credit for returned voucher'
  MACHO_REDEEM_MESSAGE = 'Macho Bucks redeemed and applied to your order'
  GIFT_REDEEMED_MESSAGE = 'Machovy Gift Certificate redeemed'
  GIFT_GIVEN_MESSAGE = 'Machovy Gift Certificate receipt'
  GIFT_RECEIVED_MESSAGE = 'A Machovy Gift Certificate for you'
  GIFT_CREDITED_MESSAGE = 'Macho Bucks Credit for you'
  GIFT_UPDATE_MESSAGE = 'Machovy Gift Certificate -- recipient email changed'
  
  
  default from: ApplicationHelper::MAILER_FROM_ADDRESS
  
  def promotion_order_email(order)
    @order = order
    
    @order.vouchers.each do |voucher|
      url = redeem_merchant_voucher_url(voucher)
      qrcode = RQRCode::QRCode.new(url, :size => RQRCode.minimum_qr_size_from_string(url))
      svg = RQRCode::Renderers::SVG::render(qrcode)
      image = MiniMagick::Image.read(svg)
      image.format("png")

      attachments[voucher.uuid + ".png"] = image.to_blob
    end
    
    mail(:to => @order.email, :subject => ORDER_MESSAGE) 
  end
  
  # WARNING -- if there are multiple vouchers per order, it will send more than one email
  def survey_email(order)
    @order = order
    
    mail(:to => @order.email, :subject => SURVEY_MESSAGE)
  end  
  
  def unredeem_email(voucher)
    @voucher = voucher
    
    mail(:to => @voucher.order.email, :bcc => ApplicationHelper::MACHOVY_MERCHANT_ADMIN, :subject => UNREDEEM_MESSAGE)
  end
  
  def macho_bucks_voucher_email(bucks)
    @voucher = bucks.voucher
    @bucks = bucks
    
    mail(:to => @bucks.user.email, :bcc => ApplicationHelper::MACHOVY_MERCHANT_ADMIN, :subject => MACHO_CREDIT_MESSAGE)
  end

  def macho_bucks_order_email(bucks)
    @order = bucks.order
    @bucks = bucks
    
    mail(:to => @bucks.user.email, :bcc => ApplicationHelper::MACHOVY_MERCHANT_ADMIN, :subject => MACHO_REDEEM_MESSAGE)
  end

  def gift_redeemed_email(certificate)
    @certificate = certificate
    
    mail(:to => @certificate.user.email, :subject => GIFT_REDEEMED_MESSAGE)
  end
  
  def gift_given_email(certificate)
    @certificate = certificate
    
    mail(:to => @certificate.user.email, :subject => GIFT_GIVEN_MESSAGE)
  end
   
  def gift_received_email(certificate)
    @certificate = certificate
    
    mail(:to => @certificate.email, :subject => GIFT_RECEIVED_MESSAGE)
  end
  
  def gift_given_user_email(certificate)
    @certificate = certificate
    
    mail(:to => @certificate.user.email, :subject => GIFT_GIVEN_MESSAGE)
  end
  
  def gift_credited_email(certificate)
    @certificate = certificate
    
    mail(:to => @certificate.email, :subject => GIFT_CREDITED_MESSAGE)
  end
  
  def gift_update_email(certificate, old_email)
    @certificate = certificate
    @old_email = old_email
    
    mail(:to => @certificate.user.email, :cc => [@old_email, @certificate.email], :subject => GIFT_UPDATE_MESSAGE)
  end
end
