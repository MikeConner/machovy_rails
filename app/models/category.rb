# == Schema Information
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  status     :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   Classification for promotions (e.g., "Adventure", "Nightlife", "Clothing")
#
# USAGE
#
# NOTES AND WARNINGS
#
# TODO boolean 'status' is odd; does it mean "active"? Consider renaming.
# TODO need unique db index on name
#
class Category < ActiveRecord::Base
  attr_accessible :name, :status
  
  has_and_belongs_to_many :promotions
  
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates_inclusion_of :status, :in => [true, false]
end
