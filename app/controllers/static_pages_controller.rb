class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:about, :mailing, :get_featured, :feedback, :make_comment]

  def about
  end
  
  def admin_index
  end

  def get_featured
	end
	
	def feedback
    @anonymous = current_user.nil?
    @categories = FeedbackShared.categories
    
    @ideas = Idea.all.sort
    if @ideas.count > FeedbackShared::MAX_IDEAS
      @ideas = @ideas[0, FeedbackShared::MAX_IDEAS]
    end 
	end
	
	def make_comment
	  if params[:comment].blank?
      flash[:alert] = 'Please enter a comment'
      
      feedback
      render 'feedback'
	  else
      FeedbackMailer.feedback_email(params[:name], params[:category], params[:comment], params[:user]).deliver
    
      redirect_to feedback_path, :notice => I18n.t('feedback_thanks')
	  end
	end
	
  # NOTE: This is temporary, just to demonstrate the connection
  def mailing
    gb = Gibbon.new
    @lists = Hash.new
    for i in 1..gb.lists['total'] do
      list_id = gb.lists['data'][i - 1]['id']
      name = gb.lists['data'][i - 1]['name']
      @lists[name] = []
      members = gb.list_members({:id => list_id})
      members['data'].map { |m| @lists[name].push(m['email']) }
    end
  end
end
