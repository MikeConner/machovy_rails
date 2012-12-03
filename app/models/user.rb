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
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  first_name             :string(24)
#  last_name              :string(48)
#  address_1              :string(50)
#  address_2              :string(50)
#  city                   :string(50)
#  state                  :string(2)
#  zipcode                :string(5)
#  phone                  :string(14)
#  optin                  :boolean         default(FALSE), not null
#  total_macho_bucks      :decimal(, )     default(0.0)
#

# CHARTER
#   Represent a registered user of the system
#
# USAGE
#
# NOTES AND WARNINGS
#   Merchants are Users with the Vendor field set (and vendor data filled out)
#   Regular users also have optional profiles, with much of the same information
#   So, vendor users should not have the option of editing their profile
#
class User < ActiveRecord::Base
  include ApplicationHelper
  
  MAX_FIRST_NAME = 24
  MAX_LAST_NAME = 48
  MAX_ADDRESS = 50
  STATE_LEN = 2
  ZIPCODE_LEN = 5
  PHONE_LEN = 14
  
  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :address_1, :address_2, :phone, :city, :state, :zipcode, :optin,
                  :role_ids, :order_ids, :category_ids, :vendor_id, :vendor_attributes, :feedbacks_attributes
         
  has_many :orders, :dependent => :restrict
  has_many :vouchers, :through => :orders
  has_many :activities, :dependent => :destroy
  has_many :feedbacks, :dependent => :restrict
  has_and_belongs_to_many :roles, :uniq => true
  has_and_belongs_to_many :categories, :uniq => true
  has_one :vendor, :dependent => :nullify
  has_many :ideas, :dependent => :destroy
  has_many :stripe_logs, :dependent => :restrict
  has_many :macho_bucks, :dependent => :destroy
  
  accepts_nested_attributes_for :vendor, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :feedbacks, :allow_destroy => true, :reject_if => :all_blank
  
  # Note that devise has a unique index on email (case sensitive?)
  validates :email, :presence => true,
                    :uniqueness => { case_sensitive: false },
                    :format => { with: EMAIL_REGEX }
  validates_inclusion_of :optin, :in => [true, false]
  validates_numericality_of :total_macho_bucks
  
  # Profile fields
  validates :first_name, :length => { maximum: MAX_FIRST_NAME }, :allow_blank => true
  validates :last_name, :length => { maximum: MAX_LAST_NAME }, :allow_blank => true
  validates :address_1, :length => { maximum: MAX_ADDRESS }, :allow_blank => true
  validates :address_2, :length => { maximum: MAX_ADDRESS }, :allow_blank => true
  validates :state, :inclusion => { in: US_STATES }, :allow_blank => true
  validates :phone, :format => { with: US_PHONE_REGEX }, :allow_blank => true
  validates :zipcode, :format => { with: US_ZIP_REGEX }, :allow_blank => true
  
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
  
  # Called after each write transaction
  def update_total_macho_bucks
    total = 0.0
    self.macho_bucks.all.each do |bucks|
      total += bucks.amount
    end
    self.total_macho_bucks = total.round(2)
    save!
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

  # Needed for devise, overriding confirmations controller to accommodate special vendor processing  
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end    
end


