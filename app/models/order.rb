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
  include ApplicationHelper
  
  attr_accessible :amount, :description, :email, :stripe_card_token, :fine_print,
                  :user_id, :promotion_id
  
  # foreign keys
  belongs_to :user
  belongs_to :promotion
    
  has_one :vendor, :through => :promotion
  has_many :vouchers, :dependent => :destroy
    
  validates_presence_of :user_id
  validates_presence_of :promotion_id
    
  validates :email, :presence => true,
                    :format => { with: EMAIL_REGEX }
  validates :amount, :presence => true,
                     :numericality => { greater_than_or_equal_to: 0.0 }
  validates_presence_of :stripe_card_token
 
  validates_associated :vouchers
       
  def save_with_payment
    if save
      charge = Stripe::Charge.create(description: self.description, card: self.stripe_card_token, amount: (self.amount*100).to_int, currency: 'usd')
      ship_address = charge.id
      save!
    end

    rescue Stripe::InvalidRequestError => error
      logger.error "Stripe error while creating customer: #{error.message}"
      errors.add :base, "There was a problem with your credit card."
      false

      rescue Stripe::CardError => error
        logger.error "Stripe error while creating customer: #{error.message}"
        errors.add :base, "There was a problem with your credit card. CARDERR"
        false
  end
end
