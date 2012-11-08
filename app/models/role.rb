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
#   SuperAdmin can do anything; ContentAdmin can write blog posts as curators, edit promotions, etc.
#   Merchants can create/edit promotions, redeem/unredeem vouchers. See Ability.rb for CanCan permissions
#
# NOTES AND WARNINGS
#   A user does not have to have a role. "Role-less" users are customers
#
class Role < ActiveRecord::Base
  SUPER_ADMIN = "SuperAdmin"
  CONTENT_ADMIN = "ContentAdmin" # Same as Curator?
  SALES_ADMIN = "SalesAdmin"
  MERCHANT = "Merchant"
  
  ROLES = [SUPER_ADMIN, CONTENT_ADMIN, MERCHANT, SALES_ADMIN]
  
  attr_accessible :name
  
  has_and_belongs_to_many :users, :uniq => true
  
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false },
                   :inclusion => { in: ROLES }
end
