# == Schema Information
#
# Table name: product_strategies
#
#  id         :integer         not null, primary key
#  delivery   :boolean         default(TRUE)
#  sku        :string(48)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   Encapsulate data for the product promotion strategy -- vouchers are still generated, but they are instantly "redeemed"
#   This is for purchasing physical items that have inherent/immediate value, and need to be shipped (e.g., gift cards)
#  
# USAGE
#   Create from factory in the create method of the controller, given the value of a hidden field with the strategy name
#   Can set delivery to false if the item should be picked up instead. The SKU can be set on promotion creation, if it exists.
#   For instance, a product number used for internal tracking. It is the same for all items. 
#
# NOTES AND WARNINGS
#   Must define the name, setup, and generate_vouchers methods. There's currently no way to do anything like a serial number for
# individual shipped items. That would have to be tracked separately, or if that feature is necessary we'd have to add it, though
# it doesn't work well within the existing workflow. There's no way to see whether they've been used; presumably the merchant
# does that by other means.
#
class ProductStrategy < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :delivery, :sku
  
  # restrict would create a circular dependency and prevent any deletions
  # nullify invalidates the promotion if you delete a strategy, but allows you to destroy a promotion
  has_one :promotion, :as => :strategy, :dependent => :nullify
  
  validates_inclusion_of :delivery, :in => [true, false]
    
  def name
    PromotionStrategyFactory::PRODUCT_STRATEGY
  end  
  
  # params are the arguments into the create method of the controller
  def setup(params)
    self.delivery = '1' == params['delivery']
    if !params['sku'].empty?
      self.sku = params['sku'].strip
    end
  end

  # generate vouchers (and save)
  # return boolean success  
  def generate_vouchers(order)
    success = true
    Voucher.transaction do
      order.quantity.times do
        voucher = order.vouchers.build(:valid_date => DateTime.now.beginning_of_day, 
                                       :redemption_date => DateTime.now.beginning_of_day, 
                                       :expiration_date => 1.year.from_now.beginning_of_day,
                                       :status => Voucher::REDEEMED,
                                       :notes => "#{order.fine_print} #{order.shipping_address}") 
        if !voucher.save
          success = false
        end  
      end   
    end
    
    success
  end
end
