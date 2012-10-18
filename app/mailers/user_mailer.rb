class UserMailer < ActionMailer::Base
  helper :application
  
  ORDER_MESSAGE = 'Thank you for your Machovy promotion order'

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
end
