class PromotionImage < ActiveRecord::Base
  attr_accessible :imageurl, :name, :mediatype
  
  has_and_belongs_to_many :promotions
  
  
  mount_uploader :imageurl, ImageUploader
end
