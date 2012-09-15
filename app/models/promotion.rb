class Promotion < ActiveRecord::Base
  attr_accessible :description, :destination, :end, :grid_weight, :limitations, :metro_id, :price, :quantity, :retail_value, :revenue_shared, :start, :teaser_image, :title, :vendor_id, :voucher_instructions, :main_image, :remote_main_image_url, :remote_teaser_image_url
  

  belongs_to :metro
  belongs_to :vendor
  has_many :orders
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promotion_images
  
  mount_uploader :main_image, ImageUploader
  
  mount_uploader :teaser_image, ImageUploader
  def ad?
    description == ""
  end

  def affiliate?
    destination != "" and description != ""
  end
  
  def remaining
    quantity - vouchers.count
    
  end
end
