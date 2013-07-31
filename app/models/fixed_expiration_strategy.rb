# == Schema Information
#
# Table name: fixed_expiration_strategies
#
#  id          :integer          not null, primary key
#  end_date    :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  delay_hours :integer          default(0), not null
#

# CHARTER
#   Encapsulate data for the fixed promotion strategy -- vouchers should expire on a fixed date
#
# USAGE
#   Create from factory in the create method of the controller, given the value of a hidden field with the strategy name
#
# NOTES AND WARNINGS
#   Must define the name, description, setup, and generate_vouchers methods
#
class FixedExpirationStrategy < ActiveRecord::Base
  attr_accessible :end_date, :delay_hours
  
  # restrict would create a circular dependency and prevent any deletions
  # nullify invalidates the promotion if you delete a strategy, but allows you to destroy a promotion
  has_one :promotion, :as => :strategy, :dependent => :nullify
  
  validates_presence_of :end_date
  validates :delay_hours, :numericality => { only_integer: true, greater_than_or_equal_to: 0 }

  def name
    PromotionStrategyFactory::FIXED_STRATEGY
  end  
  
  # Description that appears in the vendor email
  def description
    "Vouchers expire on a fixed date: #{self.end_date.try(:strftime, ApplicationHelper::DATE_FORMAT)}."
  end
  
  # params are the arguments into the create method of the controller
  def setup(params)
    self.end_date = DateTime.new(Integer(params['fixed']['end_date(1i)']),
                                 Integer(params['fixed']['end_date(2i)']),
                                 Integer(params['fixed']['end_date(3i)']))
    self.delay_hours = params[:fixed_delay]
  end

  # generate vouchers (and save)
  # return boolean success  
  def generate_vouchers(order)
    success = true
    
    Voucher.transaction do
      order.quantity.times do
        voucher = order.vouchers.build(:valid_date => Time.zone.now.beginning_of_day, 
                                       :expiration_date => self.end_date,
                                       :notes => order.fine_print, :delay_hours => self.delay_hours) 
        if !voucher.save
          success = false
        end  
      end   
    end
    
    success
  end
end
