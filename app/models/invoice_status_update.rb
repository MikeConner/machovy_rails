# == Schema Information
#
# Table name: invoice_status_updates
#
#  id                 :integer         not null, primary key
#  bitcoin_invoice_id :integer
#  status             :string(15)      default("new")
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class InvoiceStatusUpdate < ActiveRecord::Base
  MAX_STATUS_LEN = 15
  
  NEW = 'new'
  PAID = 'paid'
  CONFIRMED = 'confirmed'
  COMPLETE = 'complete'
  EXPIRED = 'expired'
  INVALID = 'invalid'
  
  VALID_STATUSES = [NEW, PAID, CONFIRMED, COMPLETE, EXPIRED, INVALID]
  
  attr_accessible :status
  
  belongs_to :bitcoin_invoice
  
  validates :status, :inclusion => { :in => VALID_STATUSES }
end
