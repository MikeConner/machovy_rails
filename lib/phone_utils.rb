module PhoneUtils
  def self.normalize_phone(phone)
    result = phone.gsub(/-|\.|\(|\)/, ' ')
    if result =~ /(\d{3}) ?(\d{3}) ?(\d{4})/
      result = "(#{$1}) #{$2}-#{$3}"
    else
      # Pass through original so it will fail validation
      phone
    end  
  end
end