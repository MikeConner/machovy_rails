# == Schema Information
#
# Table name: promotion_images
#
#  id               :integer         not null, primary key
#  caption          :string(64)
#  media_type       :string(16)
#  slideshow_image  :string(255)
#  remote_image_url :string(255)
#  promotion_id     :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

# CHARTER
#   An image that goes with a promotion.
#
# USAGE
#
# NOTES AND WARNINGS
#   A promotion can have associated "slide show" images (including different formats/versions within the uploader)
# Given the new purpose of this class, let's keep things simple and not explicitly share images between promotions with
# HABTM. If you really want to share images, you can do that using remote_urls.
#
class PromotionImage < ActiveRecord::Base
  MAX_CAPTION_LEN = 64
    
  attr_accessible :caption, :slideshow_image, :remote_image_url
  
  belongs_to :promotion
  
  mount_uploader :slideshow_image, ImageUploader
  
  validates :caption, :length => { maximum: MAX_CAPTION_LEN }, :allow_blank => true
  validates :slideshow_image, :presence => { :if => :no_image_url }
  validates :remote_image_url, :presence => { :if => :no_image }
                         
  validates_presence_of :promotion_id
  
private
  def no_image
    self.slideshow_image.blank?
  end
  
  def no_image_url
    self.remote_image_url.blank?
  end
end
