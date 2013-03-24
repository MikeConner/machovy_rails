class StaticPagesController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!, :only => [:admin_index, :merchant_contract, :mailing, :feedback_report, :activity_report, :order_report, :harlem_shake]
  before_filter :ensure_merchant, :only => [:merchant_contract]
  before_filter :ensure_admin, :only => [:mailing, :feedback_report, :activity_report, :order_report]
  
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
  
  # For download on clicking the link
  def merchant_contract
    send_data MachovyRails::Application.assets.find_asset(VendorMailer::LEGAL_AGREEMENT_FILENAME).to_s, 
              :type => "application/pdf", 
              :filename => 'VendorAgreement.pdf'
  end

  # For display in a modal dialog on signup
  def merchant_contract_html
    send_data MachovyRails::Application.assets.find_asset(VendorMailer::LEGAL_AGREEMENT_HTML).to_s, 
              :type => "text/html", 
              :disposition => 'inline'    
  end
  
  def default_gravatar
    send_file MachovyRails::Application.assets.find_asset('Machovy_Gravatar.gif').pathname, 
              :type => "image/gif", 
              :disposition => 'inline'    
  end
  
  def activity_report
    # Get top N selling promotions
    n = 10
    sales = Hash.new
    buyers = Hash.new
    Order.all.each do |o|
      if !sales.has_key?(o.promotion.title)
        sales[o.promotion.title] = 0
      end
      sales[o.promotion.title] += o.total_cost
      if !buyers.has_key?(o.user.email)
        buyers[o.user.email] = 0
      end
      buyers[o.user.email] += o.total_cost
    end
    
    @ranked_sales = sales.sort {|a,b| b[1] <=> a[1]}[0, n] 
    @ranked_buyers = buyers.sort {|a,b| b[1] <=> a[1]}[0, n] 
    
    # Get top n active users
    users = Hash.new
    clicks = Hash.new
    
    user_totals = Hash.new
    Activity.all.each do |a|
      key = a.user.email
      if !users.has_key?(key)
        users[key] = Hash.new
        user_totals[key] = 0
      end
      
      if !users[key].has_key?(a.activity_name)
        users[key][a.activity_name] = 0
      end
      users[key][a.activity_name] += 1
      user_totals[key] += 1
      
      if Activity::MONITORED_ACTIVITIES.include?(a.activity_name)
        if !clicks.has_key?(a.display_name)
          clicks[a.display_name] = Hash.new
        end
        
        title = a.activity_title
        if !clicks[a.display_name].has_key?(title)
          clicks[a.display_name][title] = 0
        end
        clicks[a.display_name][title] += 1
      end
    end
    
    top_users = user_totals.sort {|a,b| b[1] <=> a[1]}[0, n] 
    @user_activity = Hash.new
    top_users.each do |user, total|
      @user_activity[user] = users[user]
    end
    
    @columns = []
    @user_activity.each do |email, data|
      if data.keys.length > @columns.length
        @columns = data.keys.sort
      end
    end
    
    @top_clicks = Hash.new
    clicks.sort.each do |name, data|
      @top_clicks[name] = data.sort {|a,b| b[1] <=> a[1]}[0, n] 
    end
    
    render :layout => 'layouts/admin'
  end
  
  def feedback_report
    # promotion: avg based on x, % would recommend, list of comments...
    @promotion_data = Hash.new
    Feedback.all.each do |f|
      title = f.order.promotion.title
      if !@promotion_data.has_key?(title)
        @promotion_data[title] = Hash.new  
        @promotion_data[title][:cnt] = 0
        @promotion_data[title][:rec] = 0
        @promotion_data[title][:stars] = 0
        @promotion_data[title][:comments] = []
      end
      @promotion_data[title][:cnt] += 1
      @promotion_data[title][:stars] += f.stars
      if f.recommend?
        @promotion_data[title][:rec] += 1        
      end
      if !f.comments.blank?
        @promotion_data[title][:comments].push(f.comments)
      end
    end
    
    # Calculate averages, etc.
    @promotion_data.each do |title, data|
      @promotion_data[title][:rec] = (@promotion_data[title][:rec].to_f / @promotion_data[title][:cnt].to_f * 100.0).round(1)
      @promotion_data[title][:stars] = (@promotion_data[title][:stars].to_f / @promotion_data[title][:cnt].to_f).round(1)
    end
    
    render :layout => 'layouts/admin'
  end
  
  def order_report
    @orders = Order.where('created_at > ?', 3.days.ago).order('created_at desc')
    
    render :layout => 'layouts/admin'
  end
  
  def harlem_shake
    @vendor_name = 'Club Erotica'
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
