# == Schema Information
#
# Table name: positions
#
#  id            :integer         not null, primary key
#  title         :string(255)
#  description   :text
#  expiration    :datetime
#  email_contact :string(255)
#  email_subject :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

# CHARTER
#   Describe an open position at Machovy.
#
# USAGE
#
# NOTES AND WARNINGS
#
class Position < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :description, :email_contact, :email_subject, :expiration, :title
  
  validates_presence_of :description
  validates :email_contact, :presence => true, 
                            :format => { with: EMAIL_REGEX }
  validates_presence_of :email_subject
  validates_presence_of :title
  validates_presence_of :expiration
end
