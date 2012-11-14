class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :super_admin, :only => [:promote]
  before_filter :correct_user_order, :only => [:survey, :feedback]
  before_filter :correct_user, :only => [:edit_profile, :update_profile]
  before_filter :transform_phones, only: [:update_profile]
  before_filter :upcase_state, only: [:update_profile]
  
  load_and_authorize_resource

  def manage
    render :layout => 'layouts/admin'
  end
  
  def promote
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User role updated successfully'
    else
      flash[:alert] = 'Error updating user role'
    end
    
    redirect_to manage_users_path
  end
  
  def survey
    # Check to see if they've already given feedback on this order
    feedback = @user.feedbacks.where("order_id = ?", @order.id)
    if feedback.empty?
      @user.feedbacks.build(:order_id => @order.id)
      render 'survey' and return
    end
    
    render 'survey_error'
  end
  
  def feedback    
    if @user.update_attributes(params[:user])
      redirect_to root_path, :notice => I18n.t('feedback_thanks')
    else
      render 'survey'  
    end
  end
  
  def edit_profile
  end
  
  def update_profile
    if @user.update_attributes(params[:user])
      redirect_to root_path, :notice => I18n.t('profile_updated')
    else
      render 'edit_profile'  
    end
  end
  
private
  def correct_user
    @user = User.find(params[:id])
    if current_user.id != @user.id
      redirect_to root_path, :alert => I18n.t('invalid_user')  
    end    
  end
  
  def correct_user_order
    @user = User.find(params[:id])
    @order = Order.find(params[:order_id])
    
    if (current_user.id != @user.id) or (@user.id != @order.user.id)
      redirect_to root_path, :alert => I18n.t('foreign_order')  
    end
    
    rescue
      redirect_to root_path, :alert => I18n.t('invalid_order')
  end
  
  def super_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
  
  def upcase_state
    if !params[:user].nil?
      if !params[:user][:state].blank?
        params[:user][:state].upcase!
      end
    end
  end
  
  def transform_phones
    if !params[:user].nil?
      phone_number = params[:user][:phone]
      if !phone_number.blank? and (phone_number !~ /#{ApplicationHelper::US_PHONE_REGEX}/)
        params[:user][:phone] = PhoneUtils::normalize_phone(phone_number)
      end       
    end
  end  
end