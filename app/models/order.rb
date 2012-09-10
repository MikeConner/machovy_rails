class Order < ActiveRecord::Base
  attr_accessible :amount, :description, :email, :promotion_id, :stripe_card_token, :user_id
  
    validates :email, presence: true

    belongs_to :promotion
    belongs_to :user
    has_one :vendor, :through => :promotion
    
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
      charge = Stripe::Charge.create(description: self.description, card: stripe_card_token, amount: (self.amount*100).to_int, currency: 'usd')
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
