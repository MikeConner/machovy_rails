# == Schema Information
#
# Table name: orders
#
#  id                :integer         not null, primary key
#  description       :string(255)
#  email             :string(255)
#  amount            :decimal(, )
#  stripe_card_token :string(255)
#  promotion_id      :integer
#  user_id           :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  fine_print        :text
#  quantity          :integer         default(1), not null
#  charge_id         :string(255)
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

  # description isn't unique; override with Guid
  before_validation :create_slug
  
  include ApplicationHelper
  
  attr_accessible :quantity, :amount, :description, :email, :stripe_card_token, :fine_print,
                  :user_id, :promotion_id
  
  # foreign keys
  belongs_to :user
  belongs_to :promotion
    
  has_many :vouchers, :dependent => :destroy
  
  has_one :feedback, :through => :user, :source => :feedbacks
  has_one :vendor, :through => :promotion
    
  validates_presence_of :user_id
  validates_presence_of :promotion_id
    
  validates :email, :presence => true,
                    :format => { with: EMAIL_REGEX }
  validates :quantity, :presence => true,
                       :numericality => { only_integer: true, greater_than: 0 }
  validates :amount, :presence => true,
                     :numericality => { greater_than_or_equal_to: 0.0 }
  validates_presence_of :charge_id
 
  validates_associated :vouchers
       
  def total_cost(in_pennies = false)
    amount = self.quantity * self.amount
    
    if in_pennies
      amount = (amount * 100.0).round
    end
    
    amount
  end

  def merchant_share
    total_cost * (100.0 - promotion.revenue_shared) / 100.0
  end  
  
  def machovy_share
    total_cost * promotion.revenue_shared / 100.0
  end  
  
private
  # The description is just the name of the promotion and a date
  # It's not unique, and having friendly id append "-12" or something shows how many people are ordering
  def create_slug
    self.slug = SecureRandom.uuid
  end
end
