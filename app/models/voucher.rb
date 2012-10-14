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
#  issue_date      :datetime
#  order_id        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
#

# CHARTER
#   Represent a redeemable voucher generated when a user places an order for a promotion
#
# USAGE
#   See documentation for status state machine. Defaults to "Available"
#
# NOTES AND WARNINGS
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
  
  attr_accessible :expiration_date, :issue_date, :notes, :redemption_date, :status, :uuid,
                  :order_id
  
  # foreign keys
  belongs_to :order
  
  has_one :user, :through => :order
  has_one :promotion, :through => :order
  
  validates_presence_of :order_id
  
  validates_presence_of :expiration_date
  validates_presence_of :issue_date
  
  validates :status, :presence => true,
                     :length => { maximum: VOUCHER_STATUS_LEN },
                     :inclusion => { in: VOUCHER_STATUS }
  validates :uuid, :presence => true,
                   :uniqueness => true,
                   :length => { is: UUID_LEN }
  
  # Make sure time periods are consistent
  validate :time_periods
  
  def expired?
    Time.now > self.expiration_date
  end  
  
private
  # Guarantee unique by checking the database and retrying if necessary
  def create_uuid
    uid = false
    until uid
      self.uuid = format_uuid(SecureRandom.hex(5))
      uid = Voucher.find_by_uuid(self.uuid).nil?
    end
  end
  
  # Assumes a 10-digit number
  def format_uuid(raw)
    raise "Uuid must be 10 digits" unless 10 == raw.length
    
    "#{raw[0..2]}-#{raw[3..5]}-#{raw[6..9]}"
  end
  
  def time_periods
    # Don't worry about redemption_date
    if !self.expiration_date.nil? && !self.issue_date.nil?
      if self.expiration_date < self.issue_date
        self.errors.add(:base, 'Inconsistent date fields')
      end 
    end
  end
end
