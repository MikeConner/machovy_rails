# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

# CHARTER
#   Represent a registered user of the system
#
# USAGE
#
# NOTES AND WARNINGS
# ??? Need a verified status? How does email verification work? Devise/CanCan?
# ??? role gets a "Huh?" Shouldn't be string search!
# ??? Does device somehow enforce unique emails? If not, need index on db and validation
#
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :vouchers
  has_many :orders
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :vendors
  
  
  def role?(role)
      return !!self.roles.find_by_name(role.to_s.camelize)
  end
  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false }

  def super_admin?
      return !!self.roles.find_by_name("SuperAdmin")
  end
  
  def merchant?
      return !!self.roles.find_by_name("Merchant")
  end
end


