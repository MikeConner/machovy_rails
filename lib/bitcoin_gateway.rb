# CHARTER
#   BitcoinGateway API interface
#
# USAGE
#   Point to the test server for testing, or the live one for real testing (set in environment)
#
# NOTES AND WARNINGS
#
require 'singleton'
require 'bitcoin_ticker'

class BitcoinGateway
  include Singleton
    
  attr_reader :connection
  
  # Utility to convert dollars to btc using the spot price
  def estimate_btc(usd_price)
    rate = BitcoinTicker.instance.current_rate
    rate.nil? ? 'Ticker unavailable' : usd_price / rate
  end
  
  # Return Hash with invoice data; could be used to update status
  def get_invoice(id)
    response = self.connection.get "#{BITPAY_CONNECT_URL}/api/invoice/#{CGI::escape(id)}"
    puts response.inspect
    
    if 200 == response.status 
      puts "Correct status"
      data = JSON.parse(response.body)
      puts data.inspect
      
      data
    else
      puts "Got wrong status: #{response.status}"
      puts response.inspect
      
      nil
    end
  end
  
  def create_invoice(order, price, currency = 'USD', speed = DEFAULT_TRANSACTION_SPEED, notification = DEFAULT_FULL_NOTIFICATION)
    if !connected?
      raise I18n.t('no_gateway')
    end
    
    if order.nil? or bad_input_data(price, currency)
      raise I18n.t('invalid_order_data')
    end
    
    # Estimate price in bitcoin
    rate = BitcoinTicker.instance.current_rate.floor
    # If the service is down, don't fail; just try
    if !rate.nil?
      est_btc_price = price / rate
      if est_btc_price < MINIMUM_BTC_PRICE
        raise I18n.t('bitcoin_price_too_low')
      end
    end
    
    # Order id will be nil, because the order will not have been saved yet!
    id = {:user => order.user.id, :promotion => order.promotion.id, :time => Time.zone.now.try(:strftime, ApplicationHelper::DATETIME_FORMAT)}.to_json
    key = SecureRandom.hex(16)
    response = self.connection.post "#{BITPAY_CONNECT_URL}/api/invoice", 
                  { 'price' => price, 
                    'currency' => currency, 
                    'posData' => id,
                    'notificationURL' => Rails.application.routes.url_helpers.root_url(
                                         :host => Rails.application.config.action_mailer.default_url_options[:host]) + "invoice_status_updates/#{key}",
                    'itemDesc' => order.description,
                    'buyerName' => order.name,
                    'physical' => order.shipping_address_required? ? 'true' : 'false',
                    'transactionSpeed' => speed,
                    'fullNotifications' => notification }
    puts response.inspect
    
    if 200 == response.status
      puts "Correct status"
      data = JSON.parse(response.body)
      
      puts data.inspect
            
      # It has better spit back the correct posData!
      if data['posData'] != id
        raise "Invalid order response! #{data['posData']} does not match #{id}"
      end
      
      invoice = order.build_bitcoin_invoice(:invoice_id => data['id'], 
                                            :price => price, 
                                            :currency => currency, 
                                            :notification_key => key,
                                            :current_time => convert_time(data['currentTime']), 
                                            :expiration_time => convert_time(data['expirationTime']),
                                            :invoice_time => convert_time(data['invoiceTime']),
                                            :invoice_url => data['url'],
                                            :pos_data => data['posData'],
                                            :btc_price => data['btcPrice'])
      if invoice.save
        # Check status - if it's not "new", write a status update
        if 'new' != data['status']
          invoice.invoice_status_updates.create!(:status => data['status'])
        end
      else
        puts invoice.errors.full_messages
      end
    else
      puts "Got wrong status: #{response.status}"
      puts response.inspect      
 
      # create invalid object to return; add gateway response as an error
      invoice = order.build_bitcoin_invoice(:invoice_id => 'xxx', 
                                            :price => price, 
                                            :currency => currency, 
                                            :notification_key => key,
                                            :current_time => DateTime.now, 
                                            :expiration_time => DateTime.now,
                                            :invoice_time => DateTime.now,
                                            :invoice_url => 'http://failblog.cheezburger.com',
                                            :pos_data => order.id.to_s,
                                            :btc_price => 0)
      invoice.errors.add :base, response.inspect
    end
    
    invoice
  end
  
  def connected?
    !self.connection.nil?
  end
  
protected  
  def bad_input_data(price, currency)
    (price.to_i <= 0) or !BitcoinInvoice::CURRENCIES.include?(currency)
  end
  
  def convert_time(milliseconds_since_epoch)
    t = Time.at(milliseconds_since_epoch / 1000)
    DateTime.parse(t.to_s)
  end
  
  def username
    BITPAY_API_KEY
  end
  
  def initialize
    @connection = Faraday.new(:url => "#{BITPAY_CONNECT_URL}/api")
    @connection.basic_auth self.username, ""
    response = @connection.get
    if response.status != 200
      puts response.inspect
      @connection = nil
    end
    
  # Faraday will throw an exception if the connection is refused. Just fail; don't crash
  rescue
    @connection = nil
  end  
end

class InvalidGateway < BitcoinGateway
protected 
  def username
    "Completely Wrong Key"
  end
end