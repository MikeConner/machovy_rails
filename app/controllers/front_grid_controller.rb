class FrontGridController < ApplicationController
  MAX_DEALS = 100
  MAX_BLOGS = 100
  MAX_ADS = 100
  MAX_PARTNER_VIEW_DEALS = 16
   
  def index
    # Need to have a metro, or filtering will return nothing
    if session[:metro].nil?
      session[:metro] = Metro::DEFAULT_METRO
    end
    
    @active_category = session[:category]
    @active_metro = session[:metro]
    
    @deals_per_row = Promotion::DEALS_PER_ROW
    @categories = Category.roots



    # remove deals + Interests
    @local_deals =  filter_locals(@active_category, @active_metro)
    @little_blocks = filter_littleblocks(@active_category, @active_metro) 
    

    metro_id = Metro.find_by_name(@active_metro).id

    #REMOve!!!!!!!!!!!!!!
    # Remove this when no longer used    
    @promotions = filter_promotions(@active_category, @active_metro)
    @affiliates = filter_affiliates(@active_category, @active_metro) 
    @ads = filter_ads(@active_category, @active_metro)
    #END OF REMOVE????



    # Will get highest-scoring blog posts that either have no assigned promotions (and therefore no metro)
    #   Or if they do have promotions, make sure they're associated with promotions in this metro area
    @blog_posts = BlogPost.select { |p| p.displayable? and (p.metros.empty? or p.metro_ids.include?(metro_id)) }.sort
    if @blog_posts.length > MAX_BLOGS
      @blog_posts = @blog_posts[0, MAX_BLOGS]
    end
   end    
  
private
  def filter_littleblocks(category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's "All Items"
    # All means all non_exclusive, so get the list of non-exclusive ids
    # If it's defined, use the empty set so that the non_exclusive array intersection test always fails, so that it's only triggered by the direct comparison
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @promotions = Promotion.littleblocks.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @promotions = Promotion.littleblocks.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
    #if @promotions.length > MAX_DEALS
    #  @promotions = @promotions[0, MAX_DEALS]
    #end      
    
    @promotions
  end

  def filter_locals(category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's "All Items"
    # All means all non_exclusive, so get the list of non-exclusive ids
    # If it's defined, use the empty set so that the non_exclusive array intersection test always fails, so that it's only triggered by the direct comparison
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @promotions = Promotion.deals.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @promotions = Promotion.deals.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
    #if @promotions.length > MAX_DEALS
    #  @promotions = @promotions[0, MAX_DEALS]
    #end      
    
    @promotions
  end

  def filter_affiliates(category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's "All Items"
    # All means all non_exclusive, so get the list of non-exclusive ids
    # If it's defined, use the empty set so that the non_exclusive array intersection test always fails, so that it's only triggered by the direct comparison
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @promotions = Promotion.affiliates.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @promotions = Promotion.affiliates.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
    #if @promotions.length > MAX_DEALS
    #  @promotions = @promotions[0, MAX_DEALS]
    #end      
    
    @promotions
  end

def midnightguru
    
    @deals_per_row = Promotion::DEALS_PER_ROW
    non_exclusive = Category.non_exclusive.map { |c| c.id }
    @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == 'Pittsburgh') and !(p.category_ids & non_exclusive).empty? }.sort
    if @promotions.length > MAX_PARTNER_VIEW_DEALS
      @promotions = @promotions[0, MAX_PARTNER_VIEW_DEALS]
    end

    render :layout => 'layouts/affiliate'

  end

  def filter_promotions(category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's "All Items"
    # All means all non_exclusive, so get the list of non-exclusive ids
    # If it's defined, use the empty set so that the non_exclusive array intersection test always fails, so that it's only triggered by the direct comparison
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
    if @promotions.length > MAX_DEALS
      @promotions = @promotions[0, MAX_DEALS]
    end      
    
    @promotions
  end
  
  def filter_deals(category, metro)   
    selected_category = find_selection(category)
    
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      Promotion.front_page.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      Promotion.front_page.select { |p| (p.displayable? or p.zombie?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
  end
  
  def filter_ads(category, metro)
    selected_category = find_selection(category)
    
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @ads = Promotion.ads.select { |p| p.displayable? and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @ads = Promotion.ads.select { |p| p.displayable? and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
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
