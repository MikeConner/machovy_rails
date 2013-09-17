require 'net/http'
require 'phone_utils'

module EightCoupon
  SQUARE_BRAND_IMAGE = '8coupons-sq.png'
  BANNER_BRAND_IMAGE = '8coupons-med.png'
  EIGHT_COUPON_BRAND_URL = 'http://www.8coupons.com'
  
  DEAL_URL = 'http://api.8coupons.com/v1/getdeals'  
  MAX_EXTERNAL_COUPONS = 100
  
  # Get one or more randomly selected external coupons
  def self.random_coupon(metro, limit = 1)
    # Error protection; can't get less than 1
    0 == metro.external_coupons.count ? [] : metro.external_coupons.order("RANDOM()").limit([1, limit].max)
  end
  
  # Update the coupons from the API. Remove expired ones, add new ones.
  # After running this, all coupons will be unexpired.
  # Does *NOT* update existing coupons with changes. Assumes coupons with the same id are identical
  def self.update_external_coupons(metro)
    orig_count = metro.external_coupons.count
    expired = 0
    added = 0
    
    # Remove expired coupons
    metro.external_coupons.select { |c| c.expired? }.each do |coupon|
      coupon.destroy
      expired += 1
    end
    
    # Add new coupons
    uri = URI(DEAL_URL)
    # Default radius of 5 miles 
    uri.query = URI.encode_www_form(:key => EIGHT_COUPON_API_KEY, 
                                    :lat => metro.latitude, 
                                    :lon => metro.longitude, 
                                    :orderby => 'popular',
                                    :limit => MAX_EXTERNAL_COUPONS)
    res = Net::HTTP.get_response(uri)
    result = res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : []
    
    if !result.empty?
      existing_deal_ids = metro.external_coupons.map { |c| c.deal_id }
      now = Time.zone.now
      
      result.each do |deal|
        deal_id = deal['ID'].to_i
        if !existing_deal_ids.include?(deal_id) and !deal['expirationDate'].nil?
          # Not sure if API excludes expireds, so do it manually
          begin
            exp_date = Date.parse(deal['expirationDate']) 
            next if now > exp_date
                        
            metro.external_coupons.create!(:name => deal['name'],
                                           :address_1 => deal['address'],
                                           :address_2 => deal['address2'],
                                           :state => deal['state'],
                                           :city => deal['city'],
                                           :zip => deal['ZIP'],
                                           :distance => deal['distance'].to_f,
                                           :original_price => deal['dealOriginalPrice'].blank? ? nil : deal['dealOriginalPrice'].to_f,
                                           :deal_price => deal['dealPrice'].blank? ? nil : deal['dealPrice'].to_f,
                                           :deal_savings => deal['dealSavings'].blank? ? nil : deal['dealSavings'].to_f,
                                           :deal_discount => deal['dealDiscountPercent'].blank? ? nil : deal['dealDiscountPercent'].to_f,
                                           :phone => PhoneUtils.normalize_phone(deal['phone']),
                                           :disclaimer => deal['disclaimer'],
                                           :deal_info => deal['dealinfo'],
                                           :user_name => deal['user'],
                                           :user_id => deal['userID'].to_i,
                                           :deal_url => deal['URL'],
                                           :store_url => deal['storeURL'],
                                           :logo_url => deal['showLogo'],
                                           :source => deal['dealSource'],
                                           :user_name => deal['user'],
                                           :user_id => deal['userID'].to_i,
                                           :deal_id => deal_id,
                                           :deal_type_id => deal['DealTypeID'].to_i,
                                           :category_id => deal['categoryID'].to_i,
                                           :subcategory_id => deal['subcategoryID'].to_i,
                                           :title => deal['dealTitle'],
                                           :small_image_url => deal['showImageStandardSmall'],
                                           :big_image_url => deal['showImageStandardBig'],
                                           :expiration_date => exp_date,
                                           :post_date => DateTime.parse(deal['postDate']))
            added += 1
          rescue Exception => e
            puts e.inspect
            puts "Invalid exp?: #{deal['expirationDate']}"
            puts "Invalid deal : #{deal.inspect}"
          end          
        end
      end
    end
    
    puts "Original # coupons: #{orig_count}"
    puts "Removed #{expired} expired coupons"
    puts "Added #{added} new coupons"
    puts "Total # coupons: #{ExternalCoupon.count}"    
  end
end