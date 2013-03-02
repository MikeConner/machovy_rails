# == Schema Information
#
# Table name: promotions
#
#  id                   :integer         not null, primary key
#  title                :string(255)
#  description          :text
#  limitations          :text
#  voucher_instructions :text
#  teaser_image         :string(255)
#  retail_value         :decimal(, )
#  price                :decimal(, )
#  revenue_shared       :decimal(, )
#  quantity             :integer
#  start_date           :datetime
#  end_date             :datetime
#  grid_weight          :integer
#  destination          :string(255)
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  slug                 :string(255)
#  status               :string(16)      default("Proposed"), not null
#  promotion_type       :string(16)      default("Deal"), not null
#  subtitle             :string(255)
#  strategy_id          :integer
#  strategy_type        :string(255)
#  min_per_customer     :integer         default(1), not null
#  max_per_customer     :integer         default(0), not null
#  suspended            :boolean         default(FALSE), not null
#  venue_address        :string(50)
#  venue_city           :string(50)
#  venue_state          :string(2)
#  venue_zipcode        :string(10)
#  latitude             :decimal(, )
#  longitude            :decimal(, )
#  pending              :boolean         default(FALSE), not null
#  venue_name           :string(50)
#

require 'promotion_strategy_factory'

# CHARTER
#   Represent a regional offer (deal) or advertisement, placed by a particular vendor, for which a certain curator is responsible
#
# USAGE
#   See documentation for status state machine diagram. Defaults to "Proposed"
#
# NOTES AND WARNINGS
#   Cannot name a field ":type" (technically, you can if you override "inheritance_column"), as this is used by 
# the system to implement polymorphism; hence :promotion_type
#
class Promotion < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  include ApplicationHelper
  
  MAX_STR_LEN = 16
  MAX_TITLE_LEN = 100
  DEFAULT_GRID_WEIGHT = 10
  MINIMUM_REVENUE_SHARE = 10
  MAXIMUM_REVENUE_SHARE = 80
  DEFAULT_REVENUE_SHARE = 40
  QUANTITY_THRESHOLD_PCT = 0.1
  DEALS_PER_ROW = 4
  MIN_DESCRIPTION_LEN = 95
  DEFAULT_QUANTITY = 200
  DEFAULT_STRATEGY = PromotionStrategyFactory::RELATIVE_STRATEGY
  DEFAULT_DELAY = 0
  # Special value of max_per_customer that means unlimited. Note constraint in numericality validation; you can't change this value arbitrarily!
  UNLIMITED = 0
  # Amount of time to display sold old deal after it expires or sells out
  ZOMBIE_THRESHOLD = 1.week
  
  # Types
  LOCAL_DEAL = 'Deal'
  AFFILIATE = 'Affiliate'
  AD = 'Ad'
  
  # Statuses
  PROPOSED = 'Proposed'
  EDITED = 'Edited'
  MACHOVY_APPROVED = 'Approved'
  VENDOR_APPROVED = 'Vendor Approved'
  MACHOVY_REJECTED = 'Machovy Rejected'
  VENDOR_REJECTED = 'Vendor Rejected'

  # Make type explicit, rather than trying to infer from contents
  #   This is clearer, and allows changing the "rules" later if necessary
  #   Type-based code (e.g., in views) won't break if types are added or rules are changed
  PROMOTION_TYPE = [LOCAL_DEAL, AFFILIATE, AD]
  # Ads and Affiliate promotions should probably be created with "MACHOVY_APPROVED" status
  #  At any rate they also need to have a status
  PROMOTION_STATUS = [PROPOSED, EDITED, MACHOVY_APPROVED, VENDOR_APPROVED, MACHOVY_REJECTED, VENDOR_REJECTED]
  
  after_initialize :init_defaults

  attr_accessible :description, :destination, :grid_weight, :limitations, :price, :quantity, :retail_value, :revenue_shared,
                  :start_date, :end_date, :teaser_image, :remote_teaser_image_url, :main_image, :remote_main_image_url, :suspended,
                  :status, :promotion_type, :title, :voucher_instructions, :subtitle, :min_per_customer, :max_per_customer,
                  :venue_name, :venue_address, :venue_city, :venue_state, :venue_zipcode, :latitude, :longitude, :pending,
                  :metro_id, :vendor_id, :category_ids, :blog_post_ids, :promotion_image_ids, :promotion_images_attributes, 
									:teaser_image_cache, :main_image_cache

  # Mounted fields
  mount_uploader :main_image, ImageUploader  
  mount_uploader :teaser_image, ImageUploader

  # Associations
  # Foreign keys
  belongs_to :metro
  belongs_to :vendor
  belongs_to :strategy, :dependent => :destroy, :polymorphic => true
  
  # Cannot delete a promotion if there are orders for it
  has_many :orders, :dependent => :restrict
  has_many :vouchers, :through => :orders
  has_many :feedbacks, :through => :orders
  has_many :curators, :through => :blog_posts, :uniq => true
  has_many :promotion_logs, :dependent => :destroy
  has_many :promotion_images, :dependent => :destroy
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :blog_posts
  
  accepts_nested_attributes_for :promotion_images, :allow_destroy => true, :reject_if => :all_blank

  # Having a default scope activates a PG bug with has_many :through relationships with :uniq
  #   Since there's so much logic we're dealing with arrays anyway, this isn't needed
  # Order by grid weight (Promotion.all will return a list sorted by weight)
  # default_scope order(:grid_weight)
  
  # These scopes are applied on top of the default scope (i.e., they are ordered)
  scope :front_page, where("promotion_type = ? or promotion_type = ?", LOCAL_DEAL, AFFILIATE)
  scope :deals, where("promotion_type = ?", LOCAL_DEAL)
  scope :ads, where("promotion_type = ?", AD)
  scope :affiliates, where("promotion_type = ?", AFFILIATE)
  
  validates_presence_of :metro_id
  validates_presence_of :vendor_id
  
  validates :grid_weight, :numericality => { only_integer: true, greater_than: 0 }
  validates_presence_of :title
  # Deals *must* have a description
  validates :description, :presence => { :if => :deal? }
  # Non-local promotions *must* have a destination
  validates :destination, :presence => { :unless => :deal? }
  validates :status, :presence => true,
                     :length => { maximum: MAX_STR_LEN },
                     :inclusion => { in: PROMOTION_STATUS }
  validates :promotion_type, :presence => true,
                             :length => { maximum: MAX_STR_LEN },
                             :inclusion => { in: PROMOTION_TYPE }
  validates :min_per_customer, :presence => true,
                               :numericality => { only_integer: true, greater_than: 0 }
  validates :max_per_customer, :presence => true,
                               :numericality => { only_integer: true, greater_than_or_equal_to: Promotion::UNLIMITED }
  validate :voucher_limit_consistency
  
  validates_presence_of :teaser_image, :if => :image_required?
  validates_presence_of :strategy, :if => :deal?
  validates_inclusion_of :suspended, :in => [true, false]
  validates_inclusion_of :pending, :in => [true, false]
  
  # "Deal" fields
  validates :retail_value, :price, :revenue_shared, 
            :numericality => { greater_than_or_equal_to: 0.0 },
            :if => :deal?
  validates :quantity, :numericality => { only_integer: true, greater_than_or_equal_to: 1 },
            :if => :deal?
  
  validate :category_consistency
  
  # Venue address
  validates :venue_address, :length => { maximum: MAX_ADDRESS_LEN }
  validates :venue_state, :inclusion => { in: US_STATES }, :allow_blank => true
  validates :venue_zipcode, :format => { with: US_ZIP_REGEX }, :allow_blank => true
  validates_numericality_of :latitude, :allow_nil => true
  validates_numericality_of :longitude, :allow_nil => true
  
  HORNDOGS = ['jeff@machovy.com', 'adanaie@gmail.com']
  # Can this user buy the promotion? Check if his orders are > maximum/person
  def max_quantity_for_buyer(user)
    unlimited?(user) ? ApplicationHelper::MAX_INT : self.max_per_customer - user.vouchers.where('promotion_id = ?', self.id).count    
  end
  
  def unlimited?(user)
    (UNLIMITED == self.max_per_customer) or HORNDOGS.include?(user.email)
  end
  
  # Causes issues with nested attributes when enabled
  #validates_associated :promotion_images
  def padded_description
    self.description.length >= MIN_DESCRIPTION_LEN ? self.description : self.description.ljust(MIN_DESCRIPTION_LEN, ' ')
  end
  
  def expected_revenue
    (displayable? and deal?) ? self.revenue_shared / 100.0 * self.price : 0
  end
  
  # Called in views to select the proper UI for a strategy
  def strategy_name
    if self.strategy.nil?
      # Default to something reasonable
      PromotionStrategyFactory::FIXED_STRATEGY
    else
      self.strategy.name  
    end
  end
  
  # DB scope can get lost when we're filtering and otherwise processing these as arrays
  def <=>(other)
    grid_weight <=> other.grid_weight
  end
  
  def approved?
    [MACHOVY_APPROVED, VENDOR_APPROVED].include?(self.status)
  end
  
  def awaiting_vendor_action?
    [EDITED, MACHOVY_REJECTED].include?(self.status)    
  end
  
  def awaiting_machovy_action?
    [PROPOSED, VENDOR_REJECTED].include?(self.status)        
  end
  
  # today is deprecated; need to set end_date such that this works (i.e., isn't confused by partial days)
  def expired?
    !self.end_date.nil? and Time.zone.now > self.end_date
  end
  
  def started?
    self.start_date.nil? or Time.zone.now >= self.start_date
  end
  
  def any_left?
    !self.deal? or (quantity_value > self.vouchers.count)
  end
  
  # Displayable controls buy buttons; zombies and pendings should not be "displayable" (though they might be rendered using zombie/pending logic)
  def displayable?
    !self.suspended? and !self.pending? and approved? and started? and any_left? and (!expired? or open_vouchers?)
  end
  
  # A zombie is a recently expired or sold out local deal
  # Check explicitly for !displayable as a defensive measure; we don't want both at the same time
  # An expired deal with open vouchers could otherwise lead to both being true!
  def zombie?
    deal? and !displayable? and !self.suspended? and approved? and sold_out_or_expired?
  end
  
  # Display as "coming soon". 
  def coming_soon?
    deal? and !self.suspended? and approved? and self.pending?
  end
  
  def open_vouchers?
    any_open = false
    vouchers.each do |voucher|
      if voucher.open?
        any_open = true
        break
      end
    end
    
    any_open
  end
  
  def num_open_vouchers
    cnt = 0
    vouchers.each do |voucher|
      cnt += 1 if voucher.open?
    end
    
    cnt
  end
  
  # This should match the scope (scopes are DB operations)
  def ad?
    self.promotion_type == AD
  end

  def affiliate?
    self.promotion_type == AFFILIATE
  end
  
  def deal?
    self.promotion_type == LOCAL_DEAL
  end
  
  # If undefined, return a large value, so that it's never below threshold
  # Set min to 1 so that it never says "only 0 left!"
  def remaining_quantity
    quantity_value.nil? ?  ApplicationHelper::MAX_INT : [1, quantity_value - self.vouchers.count].max    
  end
  
  # There are two main cases. This is generally geared to large numbers: e.g., 100, 200, 500 available vouchers
  #   In that case, the percentage threshold will work fine.
  # But what about unique promotions where there's only 1, 2 or 5 available? The percentage thing isn't going to
  #   work then. If q * threshold < 1 (i.e., q < 10), it should always trigger "low quantity"
  def under_quantity_threshold?
    q = quantity_value
    threshold = q.nil? ? 0 : QUANTITY_THRESHOLD_PCT * q
    # quantity could be zero, in which case it's under threshold (but will say 1 left)
    # If it's 1, 1 <= 0.1*1
    !q.nil? && ((threshold < 1.0) || (self.remaining_quantity <= threshold))
  end
  
  # Apply threshold and create text to display for user
  def quantity_description
    if quantity_value.nil?
      I18n.t('plenty', :date => self.end_date.try(:strftime, ApplicationHelper::DATE_FORMAT))
    else
      under_quantity_threshold? ? I18n.t('only_n_left', :n => self.remaining_quantity) : I18n.t('plenty', :date => self.end_date.try(:strftime, ApplicationHelper::DATE_FORMAT))
    end
  end
  
  def discount
    (self.retail_value.nil? or self.price.nil?) ? 0 : [0, self.retail_value - self.price].max
  end

	def discount_pct
		self.retail_value.nil? ? 0 : discount / self.retail_value * 100.0
	end	
	
  # This is used for pagination; it shows 30/page by default
  def self.per_page
    50
  end
	
	def revenue_share_options
	  MINIMUM_REVENUE_SHARE.step(MAXIMUM_REVENUE_SHARE, 5).to_a
	end
	
  def product_order?
    ProductStrategy === self.strategy
  end
  
  def pickup_order?
    product_order? and !self.strategy.delivery?
  end
  
  def shipping_address_required?
    product_order? and self.strategy.delivery?
  end

  def mappable?
    !self.latitude.nil? && !self.longitude.nil?
  end
	
	# Returns HTML; render in views as html_safe
	def venue_location
	  if self.venue_address.blank?
	    nil
	  else
      address = ''
      address += self.venue_name + '<br>' unless self.venue_name.blank?
      address += self.venue_address + '<br>' unless self.venue_address.blank?
      address += self.venue_city + ', ' unless self.venue_city.blank?
      address += self.venue_state + '  ' unless self.venue_state.blank?
      address += self.venue_zipcode + '<br>' unless self.venue_zipcode.blank?
   
      address
	  end
	end

  # Used for geocoding; no HTML, no venue name
  def venue_geocode_location
    if self.venue_address.blank?
      nil
    else
      address = ''
      address += self.venue_address + ', ' unless self.venue_address.blank?
      address += self.venue_city + ', ' unless self.venue_city.blank?
      address += self.venue_state + ' ' unless self.venue_state.blank?
      address += self.venue_zipcode unless self.venue_zipcode.blank?
   
      address
    end
  end
private
  def init_defaults
    self.grid_weight = DEFAULT_GRID_WEIGHT if new_record?
  end
  
  # Guard against negative values (should be impossible anyway)
  def quantity_value
    self.quantity.nil? ? nil : [0, self.quantity].max
  end
  
  def voucher_limit_consistency
    if (self.max_per_customer != UNLIMITED) and (self.max_per_customer < self.min_per_customer)
      self.errors.add :base, "Max/customer (#{self.max_per_customer}) cannot be less than min/customer (#{self.min_per_customer})"
    end
  end
  
  def category_consistency
    exclusive = Category.exclusive.map { |c| c.id }
    if !(self.category_ids & exclusive).empty? and self.category_ids.count > 1
      self.errors.add :base, I18n.t('inconsistent_categories')
    end
  end
  
  # If you say (recently_sold_out? or recently_expired?), it's possible for it to show up as a zombie, then go away, then come back (Jason?)
  def sold_out_or_expired?
    exp = recently_expired?
    sold = recently_sold_out?
    if exp or sold 
      # Find out which is *first*, and make sure we're within the threshold of that, preventing it from coming back twice
      # Only have that problem if they're both true
      if exp and sold
        Time.zone.now - [self.end_date, orders.last.created_at].min <= ZOMBIE_THRESHOLD
      else
        true
      end
    else
      false  
    end
  end
  
  def recently_expired?
    expired? and (Time.zone.now - self.end_date <= ZOMBIE_THRESHOLD)
  end
  
  def recently_sold_out?
    if any_left?
      false
    else
      # Should not be zero orders in this case, but don't fail even in pathological case
      0 == orders.count ? false : Time.zone.now - orders.last.created_at <= ZOMBIE_THRESHOLD
    end
  end
  
  def image_required?
    affiliate? or ad?
  end
end
