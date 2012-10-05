# == Schema Information
#
# Table name: promotions
#
#  id                   :integer         not null, primary key
#  title                :string(255)
#  description          :text            default(""), not null
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
#  destination          :string(255)     default(""), not null
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  slug                 :string(255)
#  status               :string(32)      default("Proposed")
#

# CHARTER
#   Represent a regional offer (deal) or advertisement, placed by a particular vendor, for which a certain curator is responsible
#
# USAGE
#   See documentation for status state machine diagram. Defaults to "Proposed"
#
# NOTES AND WARNINGS
#
class Promotion < ActiveRecord::Base
  MAX_STATUS_LEN = 32
  PROPOSED = 'Proposed'
  EDITED = 'Edited'
  MACHOVY_APPROVED = 'Approved'
  VENDOR_APPROVED = 'Vendor Approved'
  MACHOVY_REJECTED = 'Machovy Rejected'
  VENDOR_REJECTED = 'Vendor Rejected'

  PROMOTION_STATUS = [PROPOSED, EDITED, MACHOVY_APPROVED, VENDOR_APPROVED, MACHOVY_REJECTED, VENDOR_REJECTED]
  
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  attr_accessible :description, :destination, :end_date, :grid_weight, :limitations, :price, :quantity, :retail_value, :revenue_shared, :start_date, 
                  :teaser_image, :title, :voucher_instructions, :main_image, :remote_main_image_url, :remote_teaser_image_url, :status,
                  :metro_id, :vendor_id, :category_ids, :blog_post_ids

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
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :blog_posts
  
  # Order by grid weight (Promotion.all will return a list sorted by weight)
  default_scope order(:grid_weight)
  
  # These scopes are applied on top of the default scope (i.e., they are ordered)
  # description and destination are guaranteed not null in the db layer
  scope :deals, where("Trim(description) != ''")
  scope :ads, where("description is null or Trim(description) = ''")
  scope :affiliates, where("Trim(description) != '' and Trim(destination) != ''")
  
  validates_presence_of :metro_id
  validates_presence_of :vendor_id
  
  validates_numericality_of :retail_value, :greater_than_or_equal_to => 0.0
  validates_numericality_of :price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :revenue_shared, :greater_than_or_equal_to => 0.0
  validates_numericality_of :quantity, { only_integer: true, greater_than_or_equal_to: 0 } 
  validates_numericality_of :grid_weight, { only_integer: true, greater_than: 0 }
  validates :status, :presence => true,
                     :length => { maximum: MAX_STATUS_LEN },
                     :inclusion => { in: PROMOTION_STATUS }
  
  def approved?
    [MACHOVY_APPROVED, VENDOR_APPROVED].include?(self.status)
  end
  
  # today is deprecated; need to set end_date such that this works (i.e., isn't confused by partial days)
  def displayable?
    approved? and Time.now <= self.end_date
  end
  
  # This should match the scope (scopes are DB operations)
  def ad?
    self.description.blank?
  end

  def affiliate?
    !self.description.blank? and !self.destination.blank?
  end
  
  # Don't return less than 0
  def remaining_quantity
    self.quantity.nil? ?  0 : [0, self.quantity - self.vouchers.count].max    
  end
end
