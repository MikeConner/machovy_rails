class IpCache < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :ip, :latitude, :longitude
  
  validates :ip, :format => { with: IP_REGEX }
  validates_numericality_of :latitude
  validates_numericality_of :longitude
end
