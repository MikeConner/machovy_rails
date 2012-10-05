# == Schema Information
#
# Table name: videos
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  destination_url :string(255)
#  active          :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

# CHARTER
#   Represent a video (multimedia format)
#
# USAGE
#
# NOTES AND WARNINGS
#
class Video < ActiveRecord::Base
  attr_accessible :active, :destination_url, :name
  
  validates_inclusion_of :active, :in => [true, false]                     
  validates_presence_of :name
  validates_presence_of :destination_url
end
