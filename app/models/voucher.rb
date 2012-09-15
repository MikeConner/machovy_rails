class Voucher < ActiveRecord::Base
  attr_accessible :expiration_date, :issue_date, :notes, :order_id, :promotion_id, :redemption_date, :status, :user_id, :uuid
  belongs_to :user
  belongs_to :order
  belongs_to :promotion
 # belongs_to :vendor,  :through => :promotion
  
  def populate_from (order)
    self.user_id = order.user_id
    self.promotion_id = order.promotion_id
    self.order_id = order.id
    self.issue_date = DateTime.now
    #EXPIRATION DATE
    #NOTES -> issue?
    self.uuid = SecureRandom.hex(10)
  end
  
  
end
