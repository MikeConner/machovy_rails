# == Schema Information
#
# Table name: stripe_logs
#
#  id         :integer         not null, primary key
#  event_id   :string(40)
#  event_type :string(40)
#  livemode   :boolean
#  event      :text
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class StripeLog < ActiveRecord::Base
  MAX_STR_LEN = 40
  EVENT_TYPES = ['account.updated',
                 'account.application.deauthorized',
                 'charge.succeeded',
                 'charge.failed',
                 'charge.refunded',
                 'charge.disputed',
                 'customer.created',
                 'customer.updated',
                 'customer.deleted',
                 'customer.subscription.created',
                 'customer.subscription.updated',
                 'customer.subscription.deleted',
                 'customer.subscription.trial_will_end',
                 'customer.discount.created',
                 'customer.discount.updated',
                 'customer.discount.deleted',
                 'invoice.created',
                 'invoice.updated',
                 'invoice.payment_succeeded',
                 'invoice.payment_failed',
                 'invoiceitem.created',
                 'invoiceitem.updated',
                  'invoiceitem.deleted',
                 'plan.created',
                 'plan.updated',
                 'plan.deleted',
                 'coupon.created',
                 'coupon.updated',
                 'coupon.deleted',
                 'transfer.created',
                 'transfer.updated',
                 'transfer.failed',
                 'ping']

  MONITORED_TYPES = ['charge.refunded',
                     'charge.failed',
                     'charge.disputed',
                     'customer.deleted',
                     'transfer.failed']
  
  # Hopefully discoverable through customer id, charge/order id, etc. -- not mandatory                
  belongs_to :user
  
  attr_accessible :event_id, :event_type, :livemode, :event,
                  :user_id
  
  scope :live, where("livemode = #{ActiveRecord::Base.connection.quoted_true}")
  scope :test, where("livemode = #{ActiveRecord::Base.connection.quoted_false}")
  
  # Could probably validate against "evt_###" pattern
  validates :event_id, :presence => true,
                       :length => { maximum: MAX_STR_LEN }
  validates :event_type, :presence => true,
                         :inclusion => { in: EVENT_TYPES }
  validates_inclusion_of :livemode, :in => [true, false]
  validates_presence_of :event
end
