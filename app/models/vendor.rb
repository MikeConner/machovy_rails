# == Schema Information
#
# Table name: vendors
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  url        :string(255)
#  facebook   :string(255)
#  phone      :string(255)
#  address_1  :string(255)
#  address_2  :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer
#

# CHARTER
#   Represent a merchant offering promotions
#
# USAGE
#   Signup as Vendor creates a Vendor object. Vendors have access to a special part of the site where they can create promotions.
# Machovy then reviews their content (see documentation for status state machine), and also ensures the legal contract is signed
# before approving a vendor's ads.
#
# NOTES AND WARNINGS
#   Strict phone formatting requires normalization in any relevant controllers before updating
# 
class Vendor < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :address_1, :address_2, :city, :facebook, :name, :phone, :state, :url, :zip,
                  :user_id
                  
  belongs_to :user
  
  has_many :promotions, :dependent => :restrict
  has_many :metros, :through => :promotions
  has_many :orders, :through => :promotions
  
  validates_presence_of :name
  validates_presence_of :address_1
  validates_presence_of :city
  validates :state, :presence => true,
                    :inclusion => { in: US_STATES }
  validates :phone, :format => { with: US_PHONE_REGEX }
  validates :zip, :format => { with: US_ZIP_REGEX }
  validates :url, :format => { with: URL_REGEX }, :allow_blank => true
  validates :facebook, :format => { with: FACEBOOK_REGEX }, :allow_blank => true
  
  # Devise creates the vendor first, then the user (when nested), so this validation breaks it
  #  Not really satisfactory to not validate it, but defer this until I understand devise better
  # I believe I could solve this by entirely replacing the devise create code, but then what happens
  #   if devise revs and it changes? That's even worse. I'd rather add only, and not change devise code.
  #validates_presence_of :user_id
  
  validates_associated :promotions
end
