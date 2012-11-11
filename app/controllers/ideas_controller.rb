class IdeasController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :destroy]
  load_and_authorize_resource
  
  def show
    @idea = Idea.find(params[:id])  
  end
  
  def create
    if @idea.update_attributes(params[:idea])
      redirect_to feedback_path, :notice => I18n.t('idea_success')
    else
      @anonymous = current_user.nil?
      @categories = FeedbackShared.categories
      
      @ideas = Idea.all.sort
      if @ideas.count > FeedbackShared::MAX_IDEAS
        @ideas = @ideas[0, FeedbackShared::MAX_IDEAS]
      end 
      render 'static_pages/feedback'
    end
  end
  
  def index
    @ideas = Idea.all.sort.paginate(:page => params[:page])
    @admin = !current_user.nil? && current_user.has_role?(Role::SUPER_ADMIN)
  end
  
  def destroy
    @idea = Idea.find(params[:id])
    @idea.destroy

    redirect_to ideas_path, :notice => 'Bad idea deleted'    
  end
end