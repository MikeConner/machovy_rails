class Voucher < ActiveRecord::Base
  attr_accessible :expiration_date, :issue_date, :notes, :order_id, :promotion_id, :redemption_date, :status, :user_id, :uuid
end
