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
#
# NOTES AND WARNINGS
#
# TODO We should have a unique index on name
# ??? Geocode for mapping?
#
class Metro < ActiveRecord::Base
  attr_accessible :name
  
  has_many :promotions
  
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates_associated :promotions
end
