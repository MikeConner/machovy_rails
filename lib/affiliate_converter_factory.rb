require 'singleton'
require 'amazon_converter'

# CHARTER
#   Factory for affiliate conversion algorithms
#
# USAGE
#   
#  Detect the converter from the url passed in. Raise exception if not found.
# 
# NOTES AND WARNINGS
#
class AffiliateConverterFactory
  include Singleton

  def create_converter(url)
    if url =~ /amazon\.com/
      AmazonConverter.new
    else
      raise "No converter defined for #{url}"
    end
  end
end


