# == Schema Information
#
# Table name: vendors
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  url        :string(255)
#  fbook      :string(255)
#  phone      :string(255)
#  address_1  :string(255)
#  address_2  :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   Represent a merchant offering promotions
#
# USAGE
#
# NOTES AND WARNINGS
# ??? Aren't they users? Should this be there? Is a Vendor a kind of user and should be subclassed? (e.g., address is optional for customers, but
#   mandatory for vendors)
# ??? Do we require a phone number?
# ??? I think we should spell out FaceBook! 
# TODO Remember to normalize phone numbers in the controller
#
class Vendor < ActiveRecord::Base
  include VendorsHelper
  
  attr_accessible :address_1, :address_2, :city, :fbook, :name, :phone, :state, :url, :zip
  
  has_many :promotions
  has_many :metros, :through => :promotions
  has_and_belongs_to_many :users

  
  validates_presence_of :name
  validates_presence_of :address_1
  validates_presence_of :city
  validates :state, :presence => true,
                    :inclusion => { in: US_STATES }
  validates_format_of :zip, { with: US_ZIP_REGEX }
  validates :phone, :format => { with: US_PHONE_REGEX }, :allow_blank => true
  validates :url, :format => { with: URL_REGEX }, :allow_blank => true
  validates :fbook, :format => { with: Regexp.union(URL_REGEX, /Facebook/i) }, :allow_blank => true
  
  validates_associated :promotions
end
