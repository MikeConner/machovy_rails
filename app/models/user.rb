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
#
class User < ActiveRecord::Base
  include ApplicationHelper
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :role_ids, :order_ids
         
  has_many :orders, :dependent => :restrict
  has_many :vouchers, :through => :orders
  has_and_belongs_to_many :roles, :uniq => true
    
  # Note that devise has a unique index on email (case sensitive?)
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }

  validates_associated :orders
  
  def has_role?(role)
      return !!self.roles.find_by_name(role)
  end
  
  def is_customer?
    0 == self.roles.count
  end
end


