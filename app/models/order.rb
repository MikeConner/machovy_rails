class Order < ActiveRecord::Base
  attr_accessible :amount, :description, :email, :promotion_id, :stripe_card_token, :user_id
  
  
    validates :email, presence: true
    belongs_to :promotion
  def save_with_payment
    Integer  i = promotion_id
    @priced =  Promotion.find(i).price
    if valid?
      charge = Stripe::Charge.create(description: email, card: stripe_card_token, amount: 44444, currency: 'usd')
      ship_address = charge.id
      save!
    end

    rescue Stripe::InvalidRequestError => error
      logger.error "Stripe error while creating customer: #{error.message}"
      errors.add :base, "There was a problem with your credit card."
      false

  end


end
