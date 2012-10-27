class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def manage
  end
  
  def survey
    @user = User.find(params[:id])
    @order = Order.find(params[:order_id])
    
    if !@order.nil?
      # Check to see if they've already given feedback on this order
      feedback = @user.feedbacks.where("order_id = ?", @order.id)
      if feedback.empty?
        @user.feedbacks.build(:order_id => @order.id)
        render 'survey' and return
      end
    end
    
    render 'survey_error'
  end
  
  def feedback
    @user = User.find(params[:id])
    @order = Order.find(params[:order_id])
    
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('feedback_thanks')
      redirect_to root_path
    else
      render 'survey'  
    end
  end
end