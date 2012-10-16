# CHARTER
#   Describe an open position at Machovy.
#
# USAGE
#   Referred to as "Position" elsewhere, but unless we're ambitious, there's no compelling reason to change
#     the name of the database table
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
