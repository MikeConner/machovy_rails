require 'singleton'

class BitcoinTicker
  include Singleton
  
  def current_rate
    uri = URI.parse("http://data.mtgox.com/api/1/BTCUSD/ticker")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
          
    response = http.request(request)                 
    if response.code == '200'
      data = JSON.parse(response.body)
      if 'success' == data['result']
        return data['return']['last_all']['value'].to_f
      end
    end
    
    nil
  end  
end