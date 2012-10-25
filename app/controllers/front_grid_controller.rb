class FrontGridController < ApplicationController
  MAX_DEALS = 8
  MAX_BLOGS = 4
  MAX_ADS = 5
  DEALS_PER_ROW = 4
  
  include ApplicationHelper
  
  before_filter :admin_only, :only => [:manage]
  
  def index
    @active_category = params[:category]
    @promotions = filter_promotions(@active_category)
    @ads = filter_ads(@active_category)
         
    @blog_posts = BlogPost.limit(MAX_BLOGS)
    
    @deals_per_row = DEALS_PER_ROW
    @categories = Category.all
  end

  def deals
    index
  end
  
  # Front grid manager
  def manage
    render 'static_pages/front_page'
  end
  
private
  def filter_promotions(category)   
    selected_category = find_selection(category)
    
    @promotions = Promotion.front_page.select { |p| p.displayable? and 
                                                    (selected_category.nil? or p.category_ids.include?(selected_category.id)) }

    if @promotions.length > MAX_DEALS
      @promotions = @promotions[0, MAX_DEALS]
    end      
    
    @promotions
  end
  
  def filter_ads(category)
    selected_category = find_selection(category)

    @ads = selected_category.nil? ? Promotion.ads.limit(MAX_ADS) : 
                                    Promotion.ads.select { |p| p.category_ids.include?(selected_category.id) }

    if @ads.length > MAX_ADS
      @ads = @ads[0, MAX_ADS]
    end      
    
    @ads
  end

  def find_selection(category)
    # "All" will not be found, so will set selected_category to nil, equivalent to no category
    category.nil? ? nil : Category.find(:first, :conditions => [ "lower(name) = ?", category.downcase ]) 
  end
    
  def admin_only
    unless admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end      
  end  
end
