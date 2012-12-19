class StaticPagesController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!, :only => [:admin_index, :merchant_contract, :mailing]
  before_filter :ensure_merchant, :only => [:merchant_contract]
  before_filter :ensure_admin, :only => [:mailing]
  
  def about
  end
  
  def faq
  end
  
  def admin_index
    render :layout => 'layouts/admin'
  end

  def get_featured
	end
	
	def terms
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
      FeedbackMailer.delay.feedback_email(params[:name], params[:category], params[:comment], params[:user])
    
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
  
  def merchant_contract
    send_data MachovyRails::Application.assets.find_asset(VendorMailer::LEGAL_AGREEMENT_FILENAME).to_s, 
              :type => "application/pdf", 
              :filename => 'VendorAgreement.pdf'
  end
  
  def default_gravatar
    send_file MachovyRails::Application.assets.find_asset('Machovy_Gravatar.gif').pathname, 
              :type => "image/gif", 
              :disposition => 'inline'    
  end
  
private
  def ensure_merchant
    if !current_user.has_role?(Role::MERCHANT) and !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('vendors_only')
    end
  end

  def ensure_admin
    if !admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end
