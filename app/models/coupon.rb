# == Schema Information
#
# Table name: coupons
#
#  id           :integer         not null, primary key
#  title        :string(64)
#  value        :integer
#  description  :text
#  slug         :string(255)
#  coupon_image :string(255)
#  vendor_id    :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

# CHARTER
#   Represent a coupon accessible through the site
#
# USAGE
#   Sales admins can put up coupons from vendors, accessible through /coupons/slug
#
# NOTES AND WARNINGS
#
class Coupon < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  
  MAX_TITLE_LEN = 64
  
  attr_accessible :description, :title, :value, :coupon_image, :remote_coupon_image_url, 
                  :vendor_id

  mount_uploader :coupon_image, ImageUploader
  
  belongs_to :vendor
  
  validates_presence_of :vendor_id
  validates_presence_of :coupon_image
  validates :title, :presence => true,
                    :length => { :maximum => MAX_TITLE_LEN }
  validates :value, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_nil => true
end
