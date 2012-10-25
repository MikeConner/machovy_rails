require 'affiliate_converter_factory'

class AjaxController < ApplicationController
  respond_to :js
  
  def affiliate_url
    converter = AffiliateConverterFactory.instance.create_converter(params[:url])
    
    render :text => converter.convert(params[:url])

  rescue 
    # Render a blank string on failure, which the JS should respond to with an error message
    # It puts the blank value into destination, which prevents the form from validating
    render :text => ""
  end
end
