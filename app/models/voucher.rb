# == Schema Information
#
# Table name: vouchers
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  redemption_date :datetime
#  status          :string(255)
#  notes           :text
#  expiration_date :datetime
#  issue_date      :datetime
#  promotion_id    :integer
#  order_id        :integer
#  user_id         :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

# CHARTER
#   Represent a redeemable voucher generated when a user places an order for a promotion
#
# USAGE
#
# NOTES AND WARNINGS
# TODO As with order, looks like business logic is in the model
# ??? What do dates mean exactly? I hope they have the same meaning across promotions!
# ??? What is status? Should it be enumerated?
# ??? Where does the uuid come from?
# ??? Why not use SecureRandom.uuid? Don't need to validate the format, since we're the ones generating it
#
class Voucher < ActiveRecord::Base
  extend FriendlyId
  friendly_id :uuid, use: [:slugged, :history]  
attr_accessible :expiration_date, :issue_date, :notes, :redemption_date, :status, :uuid,
                  :user_id, :order_id, :promotion_id
  
  # foreign keys
  belongs_to :user
  belongs_to :order
  belongs_to :promotion
 # belongs_to :vendor,  :through => :promotion
  
  validates_presence_of :user_id
  validates_presence_of :order_id
  validates_presence_of :promotion_id
  
  validates_presence_of :expiration_date
  validates_presence_of :issue_date
  validates_presence_of :redemption_date
  validates_presence_of :status
  validates_presence_of :uuid
  
  # Make sure time periods are consistent
  validate :time_periods
  
  def populate_from (order)
    self.user_id = order.user_id
    self.promotion_id = order.promotion_id
    self.order_id = order.id
    self.issue_date = DateTime.now
    #EXPIRATION DATE
    #NOTES -> issue?
    self.uuid = SecureRandom.hex(10)
  end
  
private
  def time_periods
    if (self.expiration_date < self.issue_date) or
       (self.redemption_date > self.expiration_date) or
       (self.redemption_date < self.issue_date)
      self.errors.add(:base, 'Inconsistent date fields')
    end 
  end
end
