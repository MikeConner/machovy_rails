class FrontGridController < ApplicationController
  MAX_DEALS = 8
  MAX_BLOGS = 4
  MAX_ADS = 5
  
  include ApplicationHelper
  
  before_filter :admin_only, :only => [:manage]
  
  def index
    @promotions = Promotion.front_page.select { |p| p.displayable? }
    if @promotions.length > MAX_DEALS
      @promotions.slice!(0, MAX_DEALS - 1)
    end
    
    # Will be ordered by default scope
    @blog_posts = BlogPost.limit(MAX_BLOGS)
    @ads = Promotion.ads.limit(MAX_ADS)
  end
  
  def deals
    index
  end
  
  # "Site Admin" page
  def manage
    render 'static_pages/front_page'
  end
  
private
  def admin_only
    unless admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end      
  end  
end
