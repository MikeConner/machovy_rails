require 'affiliate_converter_factory'

class AjaxController < ApplicationController
  respond_to :js
  
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
end
