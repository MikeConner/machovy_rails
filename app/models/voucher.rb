# == Schema Information
#
# Table name: vouchers
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  redemption_date :datetime
#  status          :string(16)      default("Available")
#  notes           :text
#  expiration_date :datetime
#  valid_date      :datetime
#  order_id        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
#  payment_id      :integer
#

# CHARTER
#   Represent a redeemable voucher generated when a user places an order for a promotion
#
# USAGE
#   See documentation for status state machine. Defaults to "Available"
#
# NOTES AND WARNINGS
#  There may be legal requirements and issues related to expiration and redemption that are not addressed here
#  Currently no way to set the status to EXPIRED, though the expired? function will tell you if the date has
#  passed. Probably want to do that at the promotion level (e.g., if it gets canceled, expire all the vouchers)
#
class Voucher < ActiveRecord::Base
  extend FriendlyId
  friendly_id :uuid, use: [:slugged, :history]  
  
  VOUCHER_STATUS_LEN = 16
  
  AVAILABLE = 'Available'
  REDEEMED = 'Redeemed'
  RETURNED = 'Returned'
  EXPIRED = 'Expired'
  
  VOUCHER_STATUS = [AVAILABLE, REDEEMED, RETURNED, EXPIRED]
  # For ease of data entry, looks like phone number: 98c-42a-7fe3
  UUID_LEN = 12
  
  # Remember that before_save is called *after* before_validation
  before_validation :create_uuid
  
  # For security, don't put payment_id in accessible fields
  attr_accessible :valid_date, :expiration_date, :notes, :redemption_date, :status, :uuid,
                  :order_id
  
  # foreign keys
  belongs_to :order
  belongs_to :payment
  
  has_one :user, :through => :order
  has_one :promotion, :through => :order
  has_one :macho_buck
  
  validates_presence_of :order_id
  
  validates_presence_of :expiration_date
  validates_presence_of :valid_date
  
  validates :status, :presence => true,
                     :length => { maximum: VOUCHER_STATUS_LEN },
                     :inclusion => { in: VOUCHER_STATUS }
  validates :uuid, :presence => true,
                   :uniqueness => true,
                   :length => { is: UUID_LEN }
  
  # Make sure time periods are consistent
  validate :time_periods
  
  # This is used for pagination; show 10/page by default (since the default of 30 is probably too many)
  def self.per_page
    10
  end
  
  # An open voucher is one that could still be used
  def open?
    (AVAILABLE == status) and in_redemption_period?
  end
  
  def started?
    Time.now >= self.valid_date
  end
  
  def expired?
    Time.now > self.expiration_date
  end  
  
  def in_redemption_period?
    started? and !expired?
  end
  
  # Intent is to use these switches to display buttons (or not)
  # Vendor can choose if expired (but currently not before the valid date)
  def redeemable?
    [AVAILABLE, EXPIRED].include?(status) and started?
  end
  
  # Can only return if it's available
  def returnable?
    AVAILABLE == status
  end
  
  def payment_owed?
    (REDEEMED == status) && !paid?
  end
  
  def paid?
    !payment.nil?
  end
  
private
  # Guarantee unique by checking the database and retrying if necessary
  # But don't overwrite if we're updating!
  def create_uuid
    if self.uuid.nil?
      uid = false
      until uid
        self.uuid = format_uuid(SecureRandom.hex(5))
        uid = Voucher.find_by_uuid(self.uuid).nil?
      end
    end
  end
  
  # Assumes a 10-digit number
  def format_uuid(raw)
    raise "Uuid must be 10 digits" unless 10 == raw.length
    
    "#{raw[0..2]}-#{raw[3..5]}-#{raw[6..9]}"
  end
  
  def time_periods
    # Don't worry about redemption_date
    if !self.expiration_date.nil? && !self.valid_date.nil?
      if self.expiration_date < self.valid_date
        self.errors.add(:base, 'Inconsistent date fields')
      end 
    end
  end
end
