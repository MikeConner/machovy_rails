# == Schema Information
#
# Table name: ip_caches
#
#  id         :integer          not null, primary key
#  ip         :string(16)       not null
#  latitude   :decimal(, )      not null
#  longitude  :decimal(, )      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IpCache < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :ip, :latitude, :longitude
  
  validates :ip, :format => { with: IP_REGEX }
  validates_numericality_of :latitude
  validates_numericality_of :longitude
end
