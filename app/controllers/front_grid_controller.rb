require 'fixed_front_page_layout'
require 'eight_coupon'

class FrontGridController < ApplicationController
  include ApplicationHelper
  
  MAX_PARTNER_VIEW_DEALS = 16

  def index
    @active_category = session[:category]
    if session[:metro_user].nil? and !current_user.nil? and !current_user.metro.nil?
      session[:metro_user] = current_user.metro.name
    end
    
    # Geocode on the server, if we haven't already
    if session[:metro_geocode].nil?
      location = geocode_ip(request.ip)
      if !location.nil?
        distances = Hash.new
        Metro.all.each do |metro|
          distances[metro.name] = metro.distance_from([location[:latitude], location[:longitude]])
        end
        session[:metro_geocode] = distances.sort_by{|k,v| v}.first[0]
      end   
    end
    
    # Priority of metro selections; guarantee it always falls back on something -- cannot be nil!
    # Logic duplicated in header to show current metro on all pages
    @active_metro = session[:metro_selected] || session[:metro_user] || session[:metro_geocode] || Metro::DEFAULT_METRO
    @categories = Category.roots.select { |c| c.active? }
    
    metro = Metro.find_by_name(@active_metro)
    metro_id = metro.id
    
    # If they request the home page (no page argument), generate a random layout and store it in the session.
    # Pagination can then move forwards and backwards through it. If you didn't store it, it would generate a new random layout each time --
    #   probably with a different number of pages, so the pagination wouldn't work. Reloading by hitting the logo again loads a new layout.
    if (params[:page].nil? or session[:layout].nil?) and !session[:width].nil?
      fp_layout = FixedFrontPageLayout.new(filter(Promotion.deals, @active_category, @active_metro), 
                                           filter(Promotion.nondeals, @active_category, @active_metro), 
                                           BlogPost.select { |p| p.displayable? and (p.metros.empty? or p.metro_ids.include?(metro_id)) }.sort,
                                           filter_coupons(metro, @active_category),
                                           session[:width])
      session[:layout] = fp_layout.layout
      session[:page_start] = fp_layout.page_start
      session[:page_end] = fp_layout.page_end
      session[:num_columns] = fp_layout.num_columns
    end
    
    p = params[:page].nil? ? 1 : params[:page].to_i
    @layout = (session[:layout].nil? or session[:layout].empty?) ? nil : session[:layout][session[:page_start][p]..session[:page_end][p]]
    @empty_layout = !session[:layout].nil? && session[:layout].empty?
    @mobile = 1 == session[:num_columns]
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
    if @display_banner
      @posts = BlogPost.select { |b| b.displayable? and (b.metros.empty? or b.metro_ids.include?(metro_id)) }.sort[0,4]
    end
  end    
  
  # External feed to midnightguru
  def midnightguru
    @deals_per_row = Promotion::DEALS_PER_ROW
    @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.metro.name == 'Pittsburgh') }.sort
    if @promotions.length > MAX_PARTNER_VIEW_DEALS
      @promotions = @promotions[0, MAX_PARTNER_VIEW_DEALS]
    end
    @target = "_blank"
    
    render 'external_feed', :layout => 'layouts/affiliate'
  end
  
  # External feed to Erotica
  def erotica
    @deals_per_row = Promotion::DEALS_PER_ROW
    vendor = Vendor.find_by_name('Club Erotica')
    @promotions = Promotion.front_page.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.vendor.id == vendor.id) }.sort
    @target = "_blank"

    render 'external_feed', :layout => 'layouts/affiliate'
  end
  
  # Internal feed of a given vendor's promotions, displayed on Machovy (e.g., Harlem Shake -> Erotica deals)
  def machovy_feed
    @deals_per_row = Promotion::DEALS_PER_ROW
    vendor = Vendor.find_by_name(params[:vendor])
    @promotions = vendor.nil? ? [] : Promotion.front_page.select { |p| (p.displayable? or p.zombie? or p.coming_soon?) and (p.vendor.id == vendor.id) }.sort    
    @target = nil
    
    render 'external_feed', :layout => 'layouts/machovy_feed'
  end
  
private
  def filter(promotions, category, metro)   
    selected_category = find_selection(category)
    # nil here means no category is defined, or it's Category::ALL_ITEMS_LABEL
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
  
  def filter_coupons(metro, category)
    selected_category = find_selection(category)
    
    if selected_category.nil?
      non_exclusive = Category.non_exclusive.map { |c| c.id }
      @coupons = metro.external_coupons.select { |c| !(c.category_ids & non_exclusive).empty? }
    else
      @coupons = metro.external_coupons.select { |c| c.category_ids.include?(selected_category.id) }
    end
    
    @coupons
  end
  
  def find_selection(category)
    # "All" will not be found, so will set selected_category to nil, equivalent to no category
    category.nil? ? nil : Category.find(:first, :conditions => [ "lower(name) = ?", category.downcase ]) 
  end
end
