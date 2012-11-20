class StripeController < ApplicationController
  def test
    data = JSON.parse request.body.read, :symbolize_names => true
    puts data
  
    puts "Received event with ID: #{data[:id]} Type: #{data[:type]} Mode: #{data[:livemode]}"
    
    head :ok
  end
  
  def live
    event = retrieve_event
    if !event.nil?
      puts "Valid event!"
      head :ok
    else
      head :bad_request
    end
  end
  
private
  def retrieve_event
    data = JSON.parse request.body.read, :symbolize_names => true  
    puts "Received event with ID: #{data[:id]} Type: #{data[:type]}"
  
    # Retrieving the event from the Stripe API guarantees its authenticity  
    Stripe::Event.retrieve(data[:id])    
    
  rescue
    nil
  end
end