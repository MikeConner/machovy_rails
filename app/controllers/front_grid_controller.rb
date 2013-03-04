require 'fixed_front_page_layout'

class FrontGridController < ApplicationController
  MAX_PARTNER_VIEW_DEALS = 16

  def index
    # Need to have a metro, or filtering will return nothing
    if session[:metro].nil?
      session[:metro] = Metro::DEFAULT_METRO
    end
    
    @active_category = session[:category]
    @active_metro = session[:metro]
    
    @categories = Category.roots

    metro_id = Metro.find_by_name(@active_metro).id
    
    # If they request the home page (no page argument), generate a random layout and store it in the session.
    # Pagination can then move forwards and backwards through it. If you didn't store it, it would generate a new random layout each time --
    #   probably with a different number of pages, so the pagination wouldn't work. Reloading by hitting the logo again loads a new layout.
    if (params[:page].nil? or session[:layout].nil?) and !session[:width].nil?
      session[:layout] = FixedFrontPageLayout.new(filter(Promotion.deals, @active_category, @active_metro), 
                                                  filter(Promotion.nondeals, @active_category, @active_metro), 
                                                  BlogPost.select { |p| p.displayable? and (p.metros.empty? or p.metro_ids.include?(metro_id)) }.sort,
                                                  session[:width]).layout
    end
    
    @layout = session[:layout].nil? ? nil : session[:layout].paginate(:page => params[:page])
  end    
  
  def midnightguru    
    @deals_per_row = Promotion::DEALS_PER_ROW
    non_exclusive = Category.non_exclusive.map { |c| c.id }
    @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.metro.name == 'Pittsburgh') and !(p.category_ids & non_exclusive).empty? }.sort
    if @promotions.length > MAX_PARTNER_VIEW_DEALS
      @promotions = @promotions[0, MAX_PARTNER_VIEW_DEALS]
    end
    
    render :layout => 'layouts/affiliate'
  end
  
private
  def filter(promotions, category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's "All Items"
    # All means all non_exclusive, so get the list of non-exclusive ids
    # If it's defined, use the empty set so that the non_exclusive array intersection test always fails, so that it's only triggered by the direct comparison
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @promotions = promotions.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
    else
      @promotions = promotions.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
    end
    
    @promotions
  end
  
  def find_selection(category)
    # "All" will not be found, so will set selected_category to nil, equivalent to no category
    category.nil? ? nil : Category.find(:first, :conditions => [ "lower(name) = ?", category.downcase ]) 
  end
end
