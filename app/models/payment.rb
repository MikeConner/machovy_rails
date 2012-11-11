# == Schema Information
#
# Table name: payments
#
#  id           :integer         not null, primary key
#  amount       :decimal(, )     not null
#  check_number :integer         not null
#  check_date   :date            not null
#  notes        :text
#  vendor_id    :integer         not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

# CHARTER
#   Represent a payment to a vendor.
#
# USAGE
#   Should be looking at the interface, writing a physical check, then entering it into the system. The vendor will get an email
# listing all the redeemed vouchers covered by this payment (bcc'd to Machovy)   
#
# NOTES AND WARNINGS
#
class Payment < ActiveRecord::Base
  MINIMUM_CHECK_NUMBER = 100

  attr_accessible :amount, :check_date, :check_number, :notes,
                  :vendor_id
  
  belongs_to :vendor
  
  default_scope order('check_date DESC')
  
  has_many :vouchers, :dependent => :restrict
  
  validates :amount, :presence => true,
                     :numericality => { greater_than: 0 }
  validates :check_number, :presence => true,
                           :numericality => { only_integer: true, greater_than_or_equal_to: MINIMUM_CHECK_NUMBER }
  validates_presence_of :check_date
  validates_presence_of :vendor_id
end
