require 'fixed_front_page_layout'

class FrontGridController < ApplicationController
  MAX_PARTNER_VIEW_DEALS = 16
  EROTICA_VENDOR_ID = 14

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
      fp_layout = FixedFrontPageLayout.new(filter(Promotion.deals, @active_category, @active_metro), 
                                           filter(Promotion.nondeals, @active_category, @active_metro), 
                                           BlogPost.select { |p| p.displayable? and (p.metros.empty? or p.metro_ids.include?(metro_id)) }.sort,
                                           session[:width])
      session[:layout] = fp_layout.layout
      session[:page_start] = fp_layout.page_start
      session[:page_end] = fp_layout.page_end
      session[:num_columns] = fp_layout.num_columns
    end
    
    p = params[:page].nil? ? 1 : params[:page].to_i
    @layout = (session[:layout].nil? or session[:layout].empty?) ? nil : session[:layout][session[:page_start][p]..session[:page_end][p]]
    @empty_layout = !session[:layout].nil? && session[:layout].empty?
    @mobile = 2 == session[:num_columns]
    if !@layout.nil?
      # Pages are unequal length, so I can't use the default paginate()
      # Replace the content in the collection with the current set
      # In order to keep the page count consistent, set the "total pages" to the current page length x # pages
      #   So the "total" will be different each time, but it's never displayed as such so who cares?
      cnt = session[:page_end][p] - session[:page_start][p] + 1
      @paged_layout = WillPaginate::Collection.create(p, cnt, cnt * session[:page_start].length) do |pager|
        pager.replace(@layout)
      end
    end
    
    @display_banner = session[:banner_viewed].nil? || ('false' == session[:banner_viewed])
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
  
  def erotica
    @deals_per_row = Promotion::DEALS_PER_ROW
    non_exclusive = Category.non_exclusive.map { |c| c.id }
    @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.metro.name == 'Pittsburgh') and (p.vendor.id == EROTICA_VENDOR_ID) and !(p.category_ids & non_exclusive).empty? }.sort
    if @promotions.length > MAX_PARTNER_VIEW_DEALS
      @promotions = @promotions[0, MAX_PARTNER_VIEW_DEALS]
    end

    render 'midnightguru', :layout => 'true' == params[:local] ? 'layouts/application' : 'layouts/affiliate'
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
