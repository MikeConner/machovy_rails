class StripeController < ApplicationController
  def test
    event = retrieve_event
    if !event.nil?
      puts "Valid event!"
    end
    
    render :nothing => true
  end
  
  def live
    render :nothing => true    
  end
  
private
  def retrieve_event
    data = JSON.parse request.body.read, :symbolize_names => true
    p data
  
    puts "Received event with ID: #{data[:id]} Type: #{data[:type]}"
  
    # Retrieving the event from the Stripe API guarantees its authenticity  
    Stripe::Event.retrieve(data[:id])    
    
  rescue
    nil
  end
end