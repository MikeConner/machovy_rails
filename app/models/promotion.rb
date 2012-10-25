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
  MAX_STR_LEN = 16
  DEFAULT_GRID_WEIGHT = 10
  MINIMUM_REVENUE_SHARE = 5
  QUANTITY_THRESHOLD_PCT = 0.1
  
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
  
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  attr_accessible :description, :destination, :grid_weight, :limitations, :price, :quantity, :retail_value, :revenue_shared,
                  :start_date, :end_date, :teaser_image, :remote_teaser_image_url, :main_image, :remote_main_image_url,
                  :status, :promotion_type, :title, :voucher_instructions,
                  :metro_id, :vendor_id, :category_ids, :blog_post_ids, :promotion_image_ids

  # Mounted fields
  mount_uploader :main_image, ImageUploader  
  mount_uploader :teaser_image, ImageUploader

  # Associations
  # Foreign keys
  belongs_to :metro
  belongs_to :vendor

  # Cannot delete a promotion if there are orders for it
  has_many :orders, :dependent => :restrict
  has_many :vouchers, :through => :orders
  has_many :promotion_logs, :dependent => :destroy
  has_many :promotion_images, :dependent => :destroy
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :blog_posts
  
  accepts_nested_attributes_for :promotion_images, :allow_destroy => true, :reject_if => :all_blank
  
  # Order by grid weight (Promotion.all will return a list sorted by weight)
  default_scope order(:grid_weight)
  
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
  validates_presence_of :teaser_image
  
  # "Deal" fields
  validates :retail_value, :price, :revenue_shared, 
            :numericality => { greater_than_or_equal_to: 0.0 },
            :if => :deal?
  validates :quantity, :numericality => { only_integer: true, greater_than_or_equal_to: 1 },
            :if => :deal?
  
  validates_associated :promotion_images
  
  # Not sure why I need the *args, but it croaks without it!
  def initialize(*args)
    super
    
    self.grid_weight = DEFAULT_GRID_WEIGHT
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
  
  def displayable?
    approved? and (!expired? || open_vouchers?)
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
  
  # Don't return less than 0
  def remaining_quantity
    self.quantity.nil? ?  0 : [0, self.quantity - self.vouchers.count].max    
  end
  
  # Apply threshold and create text to display for user
  def quantity_description
    if self.quantity.nil?
      "Plenty"
    else
      self.remaining_quantity < QUANTITY_THRESHOLD_PCT * self.quantity ? "Only #{self.remaining_quantity} left!" : "Plenty"
    end
  end
  
  def discount
    (self.retail_value.nil? or self.price.nil?) ? 0 : [0, self.retail_value - self.price].max
  end

	def discount_pct
		self.retail_value.nil? ? 0 : discount / self.retail_value * 100.0
	end	
end
