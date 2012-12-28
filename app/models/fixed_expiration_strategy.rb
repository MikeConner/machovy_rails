# == Schema Information
#
# Table name: fixed_expiration_strategies
#
#  id         :integer         not null, primary key
#  end_date   :datetime        not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   Encapsulate data for the fixed promotion strategy -- vouchers should expire on a fixed date
#
# USAGE
#   Create from factory in the create method of the controller, given the value of a hidden field with the strategy name
#
# NOTES AND WARNINGS
#   Must define the name, setup, and generate_vouchers methods
#
class FixedExpirationStrategy < ActiveRecord::Base
  attr_accessible :end_date
  
  # restrict would create a circular dependency and prevent any deletions
  # nullify invalidates the promotion if you delete a strategy, but allows you to destroy a promotion
  has_one :promotion, :as => :strategy, :dependent => :nullify
  
  validates_presence_of :end_date

  def name
    PromotionStrategyFactory::FIXED_STRATEGY
  end  
  
  # params are the arguments into the create method of the controller
  def setup(params)
    self.end_date = DateTime.new(Integer(params['fixed']['end_date(1i)']),
                                 Integer(params['fixed']['end_date(2i)']),
                                 Integer(params['fixed']['end_date(3i)']))
  end

  # generate vouchers (and save)
  # return boolean success  
  def generate_vouchers(order)
    success = true
    
    Voucher.transaction do
      order.quantity.times do
        voucher = order.vouchers.build(:valid_date => DateTime.now.beginning_of_day, 
                                       :expiration_date => self.end_date,
                                       :notes => order.fine_print) 
        if !voucher.save
          success = false
        end  
      end   
    end
    
    success
  end
end
