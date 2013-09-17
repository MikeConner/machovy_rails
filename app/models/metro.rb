# == Schema Information
#
# Table name: metros
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  latitude   :decimal(, )      default(40.438169), not null
#  longitude  :decimal(, )      default(-80.001875), not null
#

# CHARTER
#   Represent a geographical area where there can be promotions (probably metropolitan areas)
#
# USAGE
#   Promotions are created by Vendors and also associated with a Metro. A national vendor might create different promotions
# in different cities. Cannot delete either Vendors or Metros if there are associated Promotions.
#
# NOTES AND WARNINGS
#
class Metro < ActiveRecord::Base
  DEFAULT_METRO = 'Pittsburgh'
  
  attr_accessible :name, :latitude, :longitude
  
  # If we wanted to really reverse geocode into an address, we could add "attr_accessor :address" and say "after_validation :reverse_geocode"
  # We don't actually need an address, though, so we don't have to do this.
  # We do need "reverse_geocoded_by" so that the code gets added enabling us to call "distance_from" on it
  reverse_geocoded_by :latitude, :longitude
  
  has_many :promotions, :dependent => :restrict
  has_many :external_coupons, :dependent => :destroy
  
  # Note that the db-level index is still case-sensitive (in PG anyway)
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates_numericality_of :latitude
  validates_numericality_of :longitude
  
  validates_associated :promotions
  
  def random_coupon(limit = 1)
    EightCoupon.random_coupon(self, limit)
  end
  
  def update_external_coupons
    EightCoupon.update_external_coupons(self)
  end
end
