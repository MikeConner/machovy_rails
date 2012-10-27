# CHARTER
#   Represent feedback on a customer's order
#
# USAGE
#   Send email upon voucher redemption, inviting users to submit a survey. Capture results in a feedback object.
# Prevent them from giving feedback more than once
#
# NOTES AND WARNINGS
#
class Feedback < ActiveRecord::Base
  attr_accessible :comments, :recommend, :stars,
                  :user_id, :order_id
  
  # Users "own" these
  belongs_to :user
  belongs_to :order
  
  validates_presence_of :user_id
  validates_presence_of :order_id
  validates_inclusion_of :recommend, :in => [true, false]
  validates :stars, :presence => true,
                    :numericality => { only_integer: true, minimum: 1, maximum: 5 }
end
