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
#

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
  DEFAULT_REVENUE_SHARE = 40
  QUANTITY_THRESHOLD_PCT = 0.1
  DEALS_PER_ROW = 4
  MIN_DESCRIPTION_LEN = 95
  DEFAULT_QUANTITY = 200
  DEFAULT_STRATEGY = PromotionStrategyFactory::RELATIVE_STRATEGY
  # Special value of max_per_customer that means unlimited. Note constraint in numericality validation; you can't change this value arbitrarily!
  UNLIMITED = 0

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
                  :start_date, :end_date, :teaser_image, :remote_teaser_image_url, :main_image, :remote_main_image_url,
                  :status, :promotion_type, :title, :voucher_instructions, :subtitle, :min_per_customer, :max_per_customer,
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
  
  validates_presence_of :teaser_image
  validates_presence_of :strategy, :if => :deal?
  
  # "Deal" fields
  validates :retail_value, :price, :revenue_shared, 
            :numericality => { greater_than_or_equal_to: 0.0 },
            :if => :deal?
  validates :quantity, :numericality => { only_integer: true, greater_than_or_equal_to: 1 },
            :if => :deal?
  
  # Can this user buy the promotion? Check if his orders are > maximum/person
   def max_quantity_for_buyer(user)
    if UNLIMITED == self.max_per_customer
      ApplicationHelper::MAX_INT
    else
      self.max_per_customer - user.vouchers.where('promotion_id = ?', self.id).count
    end    
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
    !self.end_date.nil? and Time.now > self.end_date
  end
  
  def started?
    self.start_date.nil? or Time.now >= self.start_date
  end
  
  def any_left?
    !self.deal? or (quantity_value > self.vouchers.count)
  end
  
  def displayable?
    approved? and started? and any_left? and (!expired? or open_vouchers?)
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
      I18n.t('plenty', :date => self.end_date.try(:strftime, '%b %d, %Y'))
    else
      under_quantity_threshold? ? I18n.t('only_n_left', :n => self.remaining_quantity) : I18n.t('plenty', :date => self.end_date.try(:strftime, '%b %d, %Y'))
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
end
