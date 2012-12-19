# == Schema Information
#
# Table name: gift_certificates
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  amount     :integer         not null
#  email      :string(255)     not null
#  charge_id  :string(255)     not null
#  pending    :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class GiftCertificate < ActiveRecord::Base
  include ApplicationHelper
  
  DEFAULT_AMOUNT = 25
  
  attr_accessible :amount, :charge_id, :email,
                  :user_id
                  
  belongs_to :user
  
  scope :pending, where("pending = #{ActiveRecord::Base.connection.quoted_true}")
  scope :redeemed, where("pending = #{ActiveRecord::Base.connection.quoted_false}")
  
  validates_presence_of :user_id
  validates_presence_of :charge_id
  validates_inclusion_of :pending, :in => [true, false]
  validates :email, :presence => true,
                    :format => { with: EMAIL_REGEX }
  validates :amount, :presence => true,
                     :numericality => { only_integer: true, greater_than: 0 }
  validate :cannot_gift_self
  validate :can_only_gift_customer

private
  def cannot_gift_self
    if !user.nil? and !self.email.nil? and (user.email.downcase.strip == self.email.downcase.strip)
      self.errors.add :base, I18n.t('self_gift')
    end
  end
  
  def can_only_gift_customer
    recipient = self.email.nil? ? nil : User.find_by_email(self.email)
    if !recipient.nil? and !recipient.is_customer?
      self.errors.add :base, I18n.t('gift_admin')
    end
  end
end
