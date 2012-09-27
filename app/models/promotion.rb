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
#  start                :datetime
#  end                  :datetime
#  grid_weight          :integer
#  destination          :string(255)
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  curator_id           :integer
#

# CHARTER
#   Represent a regional offer (deal) or advertisement, placed by a particular vendor, for which a certain curator is responsible
#
# USAGE
#
# NOTES AND WARNINGS
#   ??? Check validations?
#
class Promotion < ActiveRecord::Base
  attr_accessible :description, :destination, :end, :grid_weight, :limitations, :metro_id, :price, :quantity, :retail_value, :revenue_shared, :start, 
                  :teaser_image, :title, :vendor_id, :voucher_instructions, :main_image, :remote_main_image_url, :remote_teaser_image_url
  
  # Mounted fields
  mount_uploader :main_image, ImageUploader  
  mount_uploader :teaser_image, ImageUploader

  # Associations
  # Foreign keys
  belongs_to :metro
  belongs_to :vendor
  belongs_to :curator

  # 1-to-many
  has_many :orders
  has_many :vouchers, :through => :orders
  
  # Many-to-many
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promotion_images
  
  # Order by grid weight (Promotion.all will return a list sorted by weight)
  default_scope order(:grid_weight)
  
  # These scopes are applied on top of the default scope (i.e., they are ordered)
  scope :active, where("description <> ''")
  scope :ads, where("description is null or Trim(description) = ''")
  scope :affiliates, where("Trim(description) != '' and Trim(destination) != ''")
  
  validates_presence_of :metro_id
  validates_presence_of :vendor_id
  validates_presence_of :curator_id
  
  validates_numericality_of :retail_value, :greater_than_or_equal_to => 0.0
  validates_numericality_of :price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :revenue_shared, :greater_than_or_equal_to => 0.0
  validates_numericality_of :quantity, { only_integer: true, greater_than_or_equal_to: 0 } 
  validates_numericality_of :grid_weight, { only_integer: true, greater_than: 0 }
  validates_associated :orders
  
  # This should match the scope (scopes are DB operations)
  def ad?
    description.nil? or description.blank?
  end

  def affiliate?
    !description.blank? and !destination.blank?
  end
  
  # Don't return less than 0
  def remaining
    quantity.nil? ?  0 : [0, quantity - vouchers.count].min    
  end
end
