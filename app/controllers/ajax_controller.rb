require 'affiliate_converter_factory'

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
  
  def metro
    session[:metro_selected] = params[:metro]

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
  
  def set_width
    session[:width] = params[:width]
    respond_to do |format|
      format.js do
        if 'true' == params[:resize]
          render :nothing => true
        else
          render :js => "window.location.href = \"#{root_path}\""
        end
      end
    end
  end
  
  def geocode
    respond_to do |format|
      format.json do
        # Use the vendor "map_address" method so that it mimics signup; vendor object just goes away
        vendor = Vendor.new(:address_1 => params['address_1'], :address_2 => params['address_2'],
                            :city => params['city'], :state => params['state'], :zip => params['zip'])
        # Validation triggers geocoding
        vendor.valid?
        render :json => { 'latitude' => vendor.latitude, 'longitude' => vendor.longitude }
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
  
  def hide_banner
    respond_to do |format|
      format.js do
        session[:banner_viewed] = params[:hidden]
        
        render :nothing => true
      end
    end
  end
  
  def set_location
    session[:latitude] = params[:latitude]
    session[:longitude] = params[:longitude]

    # Set default metro
    distances = Hash.new
    Metro.all.each do |metro|
      distances[metro.name] = metro.distance_from([session[:latitude], session[:longitude]])
    end
    session[:metro_geocode] = distances.sort_by{|k,v| v}.first[0]
    
    respond_to do |format|
      format.html { redirect_to root_path  }
      format.js { render :nothing => true }
    end
  end  
end
