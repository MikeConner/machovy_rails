class FrontGridController < ApplicationController
  include ApplicationHelper
  
  before_filter :admin_only, :only => [:manage]
  
  def index
    @promotions = Promotion.deals.limit(8)
    # Will be ordered by default scope
    @blog_posts = BlogPost.limit(4)
    @ads = Promotion.ads.limit(5)

    # add code to make sure only active categories come back!!! [ARASH!]
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
