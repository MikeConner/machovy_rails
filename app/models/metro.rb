# == Schema Information
#
# Table name: metros
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
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
  
  attr_accessible :name
  
  has_many :promotions, :dependent => :restrict
  
  # Note that the db-level index is still case-sensitive (in PG anyway)
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  
  validates_associated :promotions
end
