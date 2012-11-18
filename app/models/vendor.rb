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
#  latitude   :decimal(, )
#  longitude  :decimal(, )
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
  
  attr_accessible :address_1, :address_2, :city, :facebook, :name, :phone, :state, :url, :zip, :latitude, :longitude,
                  :user_id
                  
  belongs_to :user
  
  has_many :promotions, :dependent => :restrict
  has_many :metros, :through => :promotions, :uniq => true
  has_many :orders, :through => :promotions
  has_many :payments, :dependent => :restrict
  
  validates_presence_of :name
  validates_presence_of :address_1
  validates_presence_of :city
  validates :state, :presence => true,
                    :inclusion => { in: US_STATES }
  validates :phone, :format => { with: US_PHONE_REGEX }
  validates :zip, :format => { with: US_ZIP_REGEX }
  validates :url, :format => { with: URL_REGEX }, :allow_blank => true
  validates :facebook, :format => { with: FACEBOOK_REGEX }, :allow_blank => true
  
  validates_numericality_of :latitude, :allow_nil => true
  validates_numericality_of :longitude, :allow_nil => true
  
  # Devise creates the vendor first, then the user (when nested), so this validation breaks it
  #  Not really satisfactory to not validate it, but defer this until I understand devise better
  # I believe I could solve this by entirely replacing the devise create code, but then what happens
  #   if devise revs and it changes? That's even worse. I'd rather add only, and not change devise code.
  #validates_presence_of :user_id
  
  validates_associated :promotions
  
  def map_address
    address = ''
    address += self.address_1 + ', ' unless self.address_1.blank?
    address += self.address_2 + ' ,' unless self.address_2.blank?
    address += self.city + ', ' unless self.city.blank?
    address += self.state + ', ' unless self.state.blank?
    address += self.zip unless self.zip.blank?
    
    address
  end
  
  def mappable?
    !self.latitude.nil? && !self.longitude.nil?
  end
  
  def total_paid
    total = 0
    payments.each do |payment|
      total += payment.amount
    end
    
    total
  end
  
  def total_commission
    total = 0
    orders.each do |order|
      order.vouchers.each do |voucher|
        if voucher.payment_owed?
          total += order.machovy_share
        end
      end
    end
    
    total    
  end
  
  def amount_owed
    total = 0
    orders.each do |order|
      order.vouchers.each do |voucher|
        if voucher.payment_owed?
          total += order.merchant_share
        end
      end
    end
    
    total
  end
end
