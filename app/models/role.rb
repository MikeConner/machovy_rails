# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   What role a user (login) has in the system; affects access control and permissions
#
# USAGE
#
# NOTES AND WARNINGS
#
#   TODO: Needs a unique index in the DB for uniqueness constraint to work -- technically should have this for categories, curators, metros. 
#         If you have admins in different metro areas they'll eventually try to add duplicates. Should not be case-sensitive.
#
class Role < ActiveRecord::Base
  attr_accessible :name
  
  has_and_belongs_to_many :users
  
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
end
