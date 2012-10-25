# CHARTER
#   Convert an Amazon url to our affiliate link
#
# USAGE
#   Call convert with the url and which format you want the output to be (defaults to dp vs. gp/product)
#   You can also tell it whether or not to validate the ASIN length (defaults to the value of a constant defined here)
#
# NOTES AND WARNINGS
#   For safety, it will log an error and return the unaltered url if it's Amazon but unrecognized
# 
#   URLs in the US can be in the following formats
#     http://www.amazon.com/exec/obidos/tg/detail/-/ASIN-VALUE-HERE
#     http://www.amazon.com/gp/product/ASIN-VALUE-HERE
#     http://www.amazon.com/o/ASIN/ASIN-VALUE-HERE
#     http://www.amazon.com/dp/ASIN-VALUE-HERE
#     http://www.amazon.com/dp/product/ASIN-VALUE-HERE
#     http://www.amazon.com/<ProductName>/dp/ASIN-VALUE-HERE

class AmazonConverter
  # If we internationalize, would need a map of country codes (20 is North America)
  AFFILIATE_TAG = 'machovy-20'
  PREFIX_DETAIL = 'https://www.amazon.com/dp/'
  PREFIX_GENERAL = 'https://www.amazon.com/gp/product/'
  VALIDATE_ASIN_LEN = true
  
  FORMATS = [/\/[dg]p\/product\/(.+?)[\/\?]/, # ORDER DEPENDENCY! This has to be before the other /dp/ one
             /\/dp\/(.+?)[\/\?]/, # ALSO, $ ones have to be after the non-$ ones
             /\/o\/ASIN\/(.+?)[\/\?]/, 
             /\/tg\/detail\/.*?\/(.+?)[\/\?]/, # Repeat with $ instead of /?
             /\/[dg]p\/product\/(.+?)$/,
             /\/dp\/(.+?)$/,
             /\/o\/ASIN\/(.+?)$/,
             /\/tg\/detail\/.*?\/(.+?)$/]
  
  def convert(url, use_simple_prefix = true, validate_asin_len = VALIDATE_ASIN_LEN)
    raise "Invalid Amazon.url #{url}" if url !~ /amazon\.com/
    result = nil
    
    FORMATS.each do |format|
      if url.strip =~ /#{format}/
        asin = $1
        # validate length of asin 
        if !validate_asin_len or (10 == asin.length) or (13 == asin.length)    
          result = sprintf("%s%s?tag=%s", use_simple_prefix ? PREFIX_DETAIL : PREFIX_GENERAL, asin, AFFILIATE_TAG)
          break
        end
      end
    end
    
    if result.nil?
      Rails.logger.error "Could not extract ASIN from #{url}"
        
      url  
    else
      result
    end
  end
end