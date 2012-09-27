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
#

# CHARTER
#   Represent a customer's order to purchase a promotion
#
# USAGE
#
# NOTES AND WARNINGS
#   The email is critical here, as we use it to match a user account. We don't have a user id here, because it's possible to order 
#     without an account (i.e., without being a registered user)
#   ??? Why are there multiple vouchers? This is one order. Can a promotion contain multiple products?
#   ??? What is the description field?
#   The amount is recorded separately from the promotion because it can change mid-stream. Customers ordering Wednesday might not
#     get the same price as those ordering Monday or Thursday. 
#   ??? Is the stripe code an approval? Does it mean the sale has gone through? If not, do we need an order status? What if it fails?
#   ??? How do we validate the email? Do we to send email and get a confirmation code back?
#   ??? Does stripe_card_token need validation?
#
# TODO Get business logic out of model (need to think about it; maybe some of it belongs here in some form)
#
class Order < ActiveRecord::Base
  attr_accessible :amount, :description, :email, :promotion_id, :stripe_card_token, :user_id
  
    # foreign keys
    belongs_to :promotion
    belongs_to :user
    
    has_one :vendor, :through => :promotion
    has_many :vouchers
    
    validates_presence_of :user_id
    validates_presence_of :promotion_id
    
    validates_presence_of :email
    validates_presence_of :amount
    validates_presence_of :stripe_card_token
    
  # This looks like business logic -- shouldn't be in the model!
  def prepare_for customer
    self.email = customer.email
    self.amount = promotion.price
    self.description = promotion.vendor.name + ' promo ' + promotion.title + Date.today.to_s
    self.user = customer
  end    
  
  def save_with_payment
    Integer  i = promotion_id
    @priced =  Promotion.find(i).price
    if valid?
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
