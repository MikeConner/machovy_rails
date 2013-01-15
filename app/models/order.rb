# == Schema Information
#
# Table name: orders
#
#  id             :integer         not null, primary key
#  description    :string(255)
#  email          :string(255)
#  amount         :decimal(, )
#  promotion_id   :integer
#  user_id        :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  fine_print     :text
#  quantity       :integer         default(1), not null
#  slug           :string(255)
#  name           :string(73)
#  address_1      :string(50)
#  address_2      :string(50)
#  city           :string(50)
#  state          :string(2)
#  zipcode        :string(10)
#  transaction_id :string(15)
#  first_name     :string(24)
#  last_name      :string(48)
#

# CHARTER
#   Represent a customer's order to purchase a promotion
#
# USAGE
#   Created at point of sale, it generates one or more vouchers, which can be redeemed by the customer at the merchant (vendor)
#   Deleting an order destroys its vouchers.
#
# NOTES AND WARNINGS
#
class Order < ActiveRecord::Base
  extend FriendlyId
  friendly_id :description, use: [:slugged, :history]

  # Special value of "transaction id" for Macho Bucks transactions, which don't go through the SecureNet gateway
  # Has to be numeric, so we can't assign it "Macho Bucks" like before. Presumably the Gateway isn't going to use a 
  # transaction id that is all zeros. Alternatively, I could make the regex more complicated and use "-" or something.
  MACHO_BUCKS_TRANSACTION_ID = '000000000000000'
  
  # description isn't unique; override with Guid
  before_validation :create_slug
  before_validation :upcase_state
  
  include ApplicationHelper
  
  attr_accessible :quantity, :amount, :description, :email, :fine_print, :first_name, :last_name,
                  :name, :address_1, :address_2, :city, :state, :zipcode,
                  :user_id, :promotion_id
  
  # foreign keys
  belongs_to :user
  belongs_to :promotion
    
  has_many :vouchers, :dependent => :destroy
  
  has_one :feedback, :through => :user, :source => :feedbacks
  has_one :vendor, :through => :promotion
  has_one :macho_buck
    
  validates_presence_of :user_id
  validates_presence_of :promotion_id
    
  validates :email, :presence => true,
                    :format => { with: EMAIL_REGEX }
  validates :quantity, :presence => true,
                       :numericality => { only_integer: true, greater_than: 0 }
  validates :amount, :presence => true,
                     :numericality => { greater_than_or_equal_to: 0.0 }
  validates :transaction_id, :presence => true,
                             :length => { maximum: ActiveMerchant::Billing::MachovySecureNetGateway::TRANSACTION_ID_LEN },
                             :format => { with: /^\d+$/ }
  
  validates :first_name, :length => { maximum: User::MAX_FIRST_NAME_LEN }, :allow_blank => true
  validates :last_name, :length => { maximum: User::MAX_LAST_NAME_LEN }, :allow_blank => true
  
  validates :name, :length => { maximum: User::MAX_FIRST_NAME_LEN + User::MAX_LAST_NAME_LEN + 1 }, :presence => { :if => :shipping_address_required? }
  validates :address_1, :length => { maximum: MAX_ADDRESS_LEN }, :presence => { :if => :shipping_address_required? }
  validates :address_2, :length => { maximum: MAX_ADDRESS_LEN }, :allow_blank => true
  validates :city, :length => { maximum: MAX_ADDRESS_LEN }, :presence => { :if => :shipping_address_required? }
  validates :state, :inclusion => { in: US_STATES }, :presence => { :if => :shipping_address_required? }, 
                                                     :allow_blank => { :unless => :shipping_address_required? }
  validates :zipcode, :format => { with: US_ZIP_REGEX }, :presence => { :if => :shipping_address_required? }, 
                                                         :allow_blank => { :unless => :shipping_address_required? }
 
  validates_associated :vouchers
       
  def total_cost(in_pennies = false)
    amount = self.quantity * self.amount
    
    if in_pennies
      amount = (amount * 100.0).round
    else
      amount = amount.round(2)
    end
    
    amount
  end

  def merchant_share
    total_cost * (100.0 - promotion.revenue_shared) / 100.0
  end  
  
  def machovy_share
    total_cost * promotion.revenue_shared / 100.0
  end  
  
  def shipping_address_required?
    # Is this a product order?
    (ProductStrategy === promotion.strategy) and promotion.strategy.delivery? 
  end
  
  def shipping_address
    if shipping_address_required?
      address = 'Ship to: '
      address += self.address_1 + ', ' unless self.address_1.blank?
      address += self.address_2 + ' ,' unless self.address_2.blank?
      address += self.city + ', ' unless self.city.blank?
      address += self.state + ', ' unless self.state.blank?
      address += self.zipcode unless self.zipcode.blank?
   
      address
    else
      'For pickup'
    end    
  end
private
  # The description is just the name of the promotion and a date
  # It's not unique, and having friendly id append "-12" or something shows how many people are ordering
  def create_slug
    self.slug = SecureRandom.uuid if new_record?
  end
  
  def upcase_state
    self.state = self.state.upcase unless self.state.nil?
  end
end
