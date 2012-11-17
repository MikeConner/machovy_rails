class UserMailer < ActionMailer::Base
  helper :application
  
  ORDER_MESSAGE = 'Thank you for your Machovy promotion order'
  SURVEY_MESSAGE = 'Thanks for redeeming your voucher'
  UNREDEEM_MESSAGE = 'Your Machovy voucher is available for use'
  
  default from: ApplicationHelper::MAILER_FROM_ADDRESS
  
  def promotion_order_email(order)
    @order = order
    
    @order.vouchers.each do |voucher|
      url = redeem_merchant_voucher_url(voucher, :subdomain => ApplicationHelper::REDEMPTION_SUBDOMAIN)
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
    
    mail(:to => @voucher.order.email, :bcc => ApplicationHelper::MACHOVY_PAYMENT_ADMIN, :subject => UNREDEEM_MESSAGE)
  end
end
