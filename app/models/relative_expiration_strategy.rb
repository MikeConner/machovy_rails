# == Schema Information
#
# Table name: relative_expiration_strategies
#
#  id          :integer         not null, primary key
#  period_days :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

# CHARTER
#   Encapsulate data for the relative promotion strategy -- vouchers should expire after x days
#
# USAGE
#   Create from factory in the create method of the controller, given the value of a hidden field with the strategy name
#
# NOTES AND WARNINGS
#   Must define the name, setup, and generate_vouchers methods
#
class RelativeExpirationStrategy < ActiveRecord::Base
  attr_accessible :period_days

  AVAILABLE_PERIODS = [30, 60, 90, 180]
  DEFAULT_PERIOD = 180
  
  # restrict would create a circular dependency and prevent any deletions
  # nullify invalidates the promotion if you delete a strategy, but allows you to destroy a promotion
  has_one :promotion, :as => :strategy, :dependent => :nullify
  
  validates :period_days, :presence => true, 
                          :numericality => { only_integer: true, greater_than: 0 }
                          
  def name
    PromotionStrategyFactory::RELATIVE_STRATEGY
  end  

  # Description that appears in the vendor email
  def description
    "Vouchers expire #{self.period_days} days after purchase."
  end
                          
  def setup(params)
    self.period_days = params[:period]
  end
  
  # generate vouchers (and save)
  # return boolean success  
  def generate_vouchers(order)
    success = true
    
    Voucher.transaction do
      order.quantity.times do
        voucher = order.vouchers.build(:valid_date => DateTime.now.beginning_of_day, 
                                       :expiration_date => self.period_days.days.from_now.beginning_of_day,
                                       :notes => order.fine_print) 
        if !voucher.save
          success = false
        end  
      end   
    end
    
    success
  end  
end
