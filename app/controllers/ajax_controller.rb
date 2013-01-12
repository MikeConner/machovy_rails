require 'affiliate_converter_factory'
#require 'machovy_securenet_gateway'

class AjaxController < ApplicationController
  respond_to :js, :json
  
  include ApplicationHelper
  
  # Detect the appropriate converter from the url, and convert it
  def affiliate_url
    converter = AffiliateConverterFactory.instance.create_converter(params[:url])
    
    render :text => converter.convert(params[:url])

  rescue 
    # Render a blank string on failure, which the JS should respond to with an error message
    # It puts the blank value into destination, which prevents the form from validating
    render :text => ""
  end
  
  # Deals/Metro/Category actions are for filtering. Set the session variables, and redirect with JS
  # Some of these get called from jQuery
  def deals
    session[:deals] = params[:deals]

    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :js => "window.location.href = \"#{root_path}\"" }
    end
  end
  
  def metro
    session[:metro] = params[:metro]

    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :js => "window.location.href = \"#{root_path}\"" }
    end
  end
  
  def category
    session[:category] = params[:category]
    
    respond_to do |format|
      format.js { render :js => "window.location.href = \"#{root_path}\"" }
    end
  end
  
  def geocode
    respond_to do |format|
      format.json do
        mapping = Hash.new
        # Use the vendor "map_address" method so that it mimics signup; vendor object just goes away
        vendor = Vendor.new(:address_1 => params['address_1'], :address_2 => params['address_2'],
                            :city => params['city'], :state => params['state'], :zip => params['zip'])
        location = geocode_address(vendor.map_address)
        if !location.nil?
          mapping['latitude'] = location['lat']
          mapping['longitude'] = location['lng']
        end
        
        render :json => mapping
      end
    end
  end
  
  def validate_card
    respond_to do |format|
      format.js do
        @card = ActiveMerchant::Billing::MachovySecureNetGateway.instance.parse_card(params)
         
        if @card.valid?
          # Additional validations on the CVV
          msg = ''
          case @card.brand
          when 'visa', 'master', 'discover'
            if @card.verification_value !~ /^\d\d\d$/
              msg = "Invalid #{@card.brand} card CVV"
            end
          when 'american_express'
            if @card.verification_value !~ /^\d\d\d\d$/
              msg = 'Invalid AMEX CVV'
            end 
          end
        else
          msg = ActiveMerchant::Billing::MachovySecureNetGateway.instance.generate_card_error_msg(@card)
        end
                
        render :text => msg, :content_type => Mime::TEXT
      end
    end
  end
end
