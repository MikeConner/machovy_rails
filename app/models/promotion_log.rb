# == Schema Information
#
# Table name: promotion_logs
#
#  id           :integer          not null, primary key
#  promotion_id :integer
#  status       :string(16)       not null
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# == Schema Information
#
# Table name: promotion_logs
#
#  id           :integer         not null, primary key
#  promotion_id :integer
#  status       :string(32)      not null
#  comment      :text
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#
# CHARTER
#   A comment, by Machovy or a vendor, recording the "negotiation" that may be involved in getting a promotion approved.
# Refer to the promotion status documentation for details.
#
# USAGE
#
# NOTES AND WARNINGS
#
class PromotionLog < ActiveRecord::Base
  attr_accessible :status, :comment,
                  :promotion_id
  
  # Foreign key
  belongs_to :promotion
  
  validates_presence_of :promotion_id
  
  # Comment is optional
  validates :status, :presence => true,
                     :length => { maximum: Promotion::MAX_STR_LEN },
                     :inclusion => { in: Promotion::PROMOTION_STATUS }
end
