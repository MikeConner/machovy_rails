# == Schema Information
#
# Table name: promotion_images
#
#  id                         :integer         not null, primary key
#  caption                    :string(64)
#  media_type                 :string(16)
#  slideshow_image            :string(255)
#  remote_slideshow_image_url :string(255)
#  promotion_id               :integer
#  created_at                 :datetime        not null
#  updated_at                 :datetime        not null
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
    
  attr_accessible :caption, :slideshow_image, :remote_slideshow_image_url
  attr_accessor :I3crop_x, :I3crop_y, :I3crop_w, :I3crop_h

  belongs_to :promotion
  
  mount_uploader :slideshow_image, ImageUploader
  process_in_background :slideshow_image
  
  validates :caption, :length => { maximum: MAX_CAPTION_LEN }, :allow_blank => true
      
  # Validating this causes problems with nested attributes                      
  # validates_presence_of :promotion_id
  validates_presence_of :slideshow_image
end
