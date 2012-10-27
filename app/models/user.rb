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
#  stripe_id              :string(255)
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
                  :role_ids, :order_ids, :vendor_id, :vendor_attributes, :feedbacks_attributes
         
  has_many :orders, :dependent => :restrict
  has_many :vouchers, :through => :orders
  has_many :activities, :dependent => :destroy
  has_many :feedbacks, :dependent => :restrict
  has_and_belongs_to_many :roles, :uniq => true
  has_one :vendor, :dependent => :nullify
  
  accepts_nested_attributes_for :vendor, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :feedbacks, :allow_destroy => true, :reject_if => :all_blank
  
  # Note that devise has a unique index on email (case sensitive?)
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }

  # Causes issues with feedback
  #validates_associated :orders
  
  def has_role?(role)
      return !!self.roles.find_by_name(role)
  end
  
  def is_customer?
    0 == self.roles.count
  end
  
  def log_activity(obj)
    activity = self.activities.build
    activity.init_activity(obj)
    activity.save    
  end
  
  # Retrieve the stripe customer object for this user. One twist is that the user could have been deleted
  #   externally. If that's the case, the object will come back "deleted". Return nil if this happens.
  def stripe_customer_obj
    obj = self.stripe_id.blank? ? nil : Stripe::Customer.retrieve(self.stripe_id)
    (obj.nil? or (obj.respond_to?(:deleted) and obj.deleted)) ? nil : obj 
    
  rescue Stripe::InvalidRequestError => error
    # Return value of puts is nil, which is what I want to return on exception anyway
    puts "Stripe error: #{error.message}"
  end
end


