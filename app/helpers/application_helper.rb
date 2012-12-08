module ApplicationHelper
  include ERB::Util
  
  # Plus DC and territories
  US_STATES = %w(AK AL AR AS AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MP MS 
                 MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY )
  US_PHONE_REGEX = /^\(\d\d\d\) \d\d\d\-\d\d\d\d$/
  URL_REGEX = /^((http|https)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?\/?([a-zA-Z0-9\-\._\?\,\'\/\\\+&amp;%\$#\=~])*[^\.\,\)\(\s]$/
  FACEBOOK_REGEX = /^(http\:\/\/)?(www\.)?facebook\.com\/\S+$/

  US_ZIP_REGEX = /^\d\d\d\d\d(-\d\d\d\d)?$/
  EMAIL_REGEX = /^\w.*?@\w.*?\.\w+$/
  
  INVALID_EMAILS = ["joe", "joe@", "gmail.com", "@gmail.com", "@Actually_Twitter", "joe.mama@gmail", "fish@.com", "fish@biz.", "test@com"]
  VALID_EMAILS = ["j@z.com", "jeff.bennett@pittsburghmoves.com", "fish_42@verizon.net", "a.b.c.d@e.f.g.h.biz"]

  MAILER_FROM_ADDRESS = 'deals@machovy.com'
  MACHOVY_MERCHANT_ADMIN = 'arash@machovy.com'
  MACHOVY_FEEDBACK_ADMIN = 'arash@machovy.com'
  
  SMTP_PASSWORD = '%%))$$@macho'
  
  NUMBER_WORDS = { 1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five', 
                   6 => 'six', 7 => 'seven', 8 => 'eight', 9 => 'nine', 10 => 'ten' }
  MAX_INT = (2**(0.size * 8 - 2) - 1)
  PRIVACY_POLICY_LINK = 'http://www.iubenda.com/privacy-policy/685133'

  def admin_user?
    user_signed_in? && (current_user.has_role?(Role::SUPER_ADMIN) || 
                        current_user.has_role?(Role::CONTENT_ADMIN) || 
                        current_user.has_role?(Role::SALES_ADMIN))
  end
  
  def number_to_word(num)
    if NUMBER_WORDS.has_key?(num)
      NUMBER_WORDS[num]
    else
      num
    end
  end

  # Returns the Gravatar (http://gravatar.com/) for the given user. 
  def gravatar_for(user, options = { size: 100 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase) 
    gravatar_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{options[:size]}" 
    image_tag(gravatar_url, class: "gravatar", title: options[:title])
  end
  
  def geocode_address(address)
    uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{u address}&sensor=false")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
          
    response = http.request(request)                 
    if response.code == '200'
      result = JSON.parse(response.body)
      # 'lat', 'lng'
      result['results'][0]['geometry']['location']
    else
      nil
    end
    
  rescue
    puts "Could not convert #{address}"
  end
end
