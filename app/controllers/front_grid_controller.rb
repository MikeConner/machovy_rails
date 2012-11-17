class FrontGridController < ApplicationController
  MAX_DEALS = 8
  MAX_BLOGS = 4
  MAX_ADS = 4
  DEFAULT_METRO = 'Pittsburgh'
  
  def index
    # Need to have a metro, or filtering will return nothing
    if session[:metro].nil?
      session[:metro] = DEFAULT_METRO
    end
    
    @active_category = session[:category]
    @active_metro = session[:metro]
    
    @deals_per_row = Promotion::DEALS_PER_ROW
    @categories = Category.all

    if session[:deals] == 'true'
      @promotions = filter_deals(@active_category, @active_metro)
    else  
      @promotions = filter_promotions(@active_category, @active_metro)
      @ads = filter_ads(@active_category, @active_metro)
      metro_id = Metro.find_by_name(@active_metro).id
      # Will get highest-scoring blog posts that either have no assigned promotions (and therefore no metro)
      #   Or if they do have promotions, make sure they're associated with promotions in this metro area
      @blog_posts = BlogPost.select { |p| p.displayable? and (p.metros.empty? or p.metro_ids.include?(metro_id)) }.sort
      if @blog_posts.length > MAX_BLOGS
        @blog_posts = @blog_posts[0, MAX_BLOGS]
      end
     end    
  end
    
private
  def filter_promotions(category, metro)   
    selected_category = find_selection(category)

    @promotions = Promotion.front_page.select { |p| p.displayable? and (p.metro.name == metro) and
                                                    (selected_category.nil? or p.category_ids.include?(selected_category.id)) }.sort
    if @promotions.length > MAX_DEALS
      @promotions = @promotions[0, MAX_DEALS]
    end      
    
    @promotions
  end
  
  def filter_deals(category, metro)   
    selected_category = find_selection(category)
    
    Promotion.all.select { |p| p.displayable? and (p.metro.name == metro) and
                               (selected_category.nil? or p.category_ids.include?(selected_category.id)) }.sort
  end
  
  def filter_ads(category, metro)
    selected_category = find_selection(category)

    @ads = selected_category.nil? ? 
        Promotion.ads.select { |p| p.metro.name == metro }.sort : 
        Promotion.ads.select { |p| (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort

    if @ads.length > MAX_ADS
      @ads = @ads[0, MAX_ADS]
    end      
    
    @ads
  end

  def find_selection(category)
    # "All" will not be found, so will set selected_category to nil, equivalent to no category
    category.nil? ? nil : Category.find(:first, :conditions => [ "lower(name) = ?", category.downcase ]) 
  end
end
