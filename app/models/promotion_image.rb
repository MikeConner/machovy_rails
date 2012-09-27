# == Schema Information
#
# Table name: promotion_images
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  imageurl   :string(255)
#  mediatype  :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   An image that goes with a promotion.
#
# USAGE
#
# NOTES AND WARNINGS
#   A promotion can have more than one image (including different formats/versions within the uploader)
#   An image can also be shared among several promotions
#   ??? Is this URL an Amazon path? Format validation?
#   ??? Supported media types correct?
#
class PromotionImage < ActiveRecord::Base
  SUPPORTED_MEDIA_TYPES = ['png', 'jpg']
  
  attr_accessible :imageurl, :name, :mediatype
  
  has_and_belongs_to_many :promotions
  
  mount_uploader :imageurl, ImageUploader
  
  validates_presence_of :name
  validates_presence_of :imageurl
  validates :mediatype, :presence => true,
                        :inclusion => { in: SUPPORTED_MEDIA_TYPES }
end
