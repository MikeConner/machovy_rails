require 'singleton'
require 'fixed_expiration_strategy'

#
# CHARTER
#   Factory for promotion strategies. Trying to encode all the complex logic of widely varying promotion types
# (e.g., 2-for-1, time-limited, 1-max, min-max, etc.) in the Promotion object would lead to 5 or 6 new fields with very
# complex interactions, and probably different meanings in different contexts. Good luck testing and maintaining that :-)
#   Instead, encapsulate it in a promotion strategy object. 
#
# USAGE 
#   Vendors choose the strategy for a given promotion, which the controller uses to create a new promotion *and* 
# a new concrete strategy object. The view would query this object about which GUI to display (or the controller might 
# invoke a separate view if it's more than a couple switches).
#
#   An instance of this strategy might contain data gathered in the creation view (e.g., the interval for a recurring
# promotion, or minimum and maximum user limits) that is specific to this promotion.
#
# NOTES AND WARNINGS
#
class PromotionStrategyFactory
  include Singleton

  def create_promotion_strategy(name, params)
    if 'Fixed' == name
      strategy = FixedExpirationStrategy.new
    elsif 'Relative' == name
      strategy = RelativeExpirationStrategy.new
    else
      raise "No strategy defined for #{name}"
    end
    
    strategy.setup(params)
    
    strategy
  end  
end