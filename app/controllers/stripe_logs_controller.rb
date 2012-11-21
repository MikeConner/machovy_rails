class StripeLogsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :ensure_admin, :only => [:index, :show]

  include ApplicationHelper
  
  def test
    body = request.body.read
    
    data = JSON.parse body, :symbolize_names => true
    logger.info "Received event with ID: #{data[:id]} Type: #{data[:type]} Mode: #{data[:livemode]}"
    if StripeLog::MONITORED_TYPES.include?(data[:type])
      StripeLog.create!(:event_id => data[:id], :event_type => data[:type], :livemode => data[:livemode], :event => body)
    end
    
    head :ok
  end
  
  def live
    event = retrieve_event
    if !event.nil?
      head :ok
    else
      head :bad_request
    end
  end
  
  def index
    @stripe_logs = 'true' == params[:livemode] ? StripeLog.live.paginate(:page => params[:page]) : 
                                                 StripeLog.test.paginate(:page => params[:page])
    @event_type = 'true' == params[:livemode] ? "Live" : "Test"
    
    render :layout => 'layouts/admin'
  end
  
  def show
    @event = StripeLog.find(params[:id])
    @event_type = 'true' == @event.livemode? ? "Live" : "Test"
  end
  
private
  def ensure_admin
    if !admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end

  def retrieve_event
    # data[:data][:object][:description]/[:customer]/[:card]/[:fee]/[:amount]
    data = JSON.parse request.body.read, :symbolize_names => true  
    logger.info "Received event with ID: #{data[:id]} Type: #{data[:type]} Mode: #{data[:livemode]}"
  
    # Retrieving the event from the Stripe API guarantees its authenticity  
    Stripe::Event.retrieve(data[:id])    
    
  rescue
    nil
  end
end