class Promotion < ActiveRecord::Base
  scope :deal, where("description <> ''")
  scope :advert, where("Trim(description) = '' or description is null")
  
  attr_accessible :description, :destination, :end, :grid_weight, :limitations, :metro_id, :price, :quantity, :retail_value, :revenue_shared, :start, :teaser_image, :title, :vendor_id, :voucher_instructions, :main_image, :remote_main_image_url, :remote_teaser_image_url
  
  validates :metro, presence: true
  validates :vendor, presence: true

  belongs_to :metro
  belongs_to :vendor
  has_many :orders
  has_many :vouchers, :through => :orders
  
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promotion_images
  belongs_to :curator
  
  mount_uploader :main_image, ImageUploader
  
  mount_uploader :teaser_image, ImageUploader
  def ad?
    description.to_s.strip == ""
  end

  def affiliate?
    destination.to_s.strip != "" and description.to_s.strip != ""
  end
  
  def remaining
    quantity - vouchers.count
    
  end
end
