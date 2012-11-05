# == Schema Information
#
# Table name: videos
#
#  id              :integer         not null, primary key
#  destination_url :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  title           :string(50)
#  curator_id      :integer
#  caption         :text
#  slug            :string(255)
#

# CHARTER
#   Represent a video (multimedia format)
#
# USAGE
#
# NOTES AND WARNINGS
#
class Video < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  MAX_TITLE_LEN = 50
  
  attr_accessible :title, :caption, :destination_url,
                  :curator_id
  
  belongs_to :curator
  
  default_scope order('created_at DESC')
    
  validates_presence_of :curator_id
  
  validates_presence_of :title
  validates_presence_of :caption
  validates_presence_of :destination_url
end
