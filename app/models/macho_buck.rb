# == Schema Information
#
# Table name: macho_bucks
#
#  id         :integer         not null, primary key
#  amount     :decimal(, )     not null
#  notes      :text
#  admin_id   :integer
#  user_id    :integer
#  voucher_id :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  order_id   :integer
#

class MachoBuck < ActiveRecord::Base
  attr_accessible :amount, :notes,
                  :user_id, :voucher_id, :order_id, :admin_id
  
  after_save :update_user_total
  
  belongs_to :user
  # If the bucks come from returning a voucher
  belongs_to :voucher
  # If the bucks are used in an order
  belongs_to :order
  # If an admin adjusts the total
  belongs_to :admin, :class_name => 'User'
  
  validates_presence_of :user_id
  validates_numericality_of :amount
  validate :super_admin
  
private
  def super_admin
    if !self.admin.nil? and !self.admin.has_role?(Role::SUPER_ADMIN)
      self.errors.add(:base, 'Admin must be a super admin') 
    end
  end
  
  def update_user_total
    self.user.update_total_macho_bucks
  end
end
