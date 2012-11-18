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
#  source          :string(24)
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
  MAX_SOURCE_LEN = 24
  YOU_TUBE = 'YouTube'
  EMBEDDING_SOURCES = [YOU_TUBE]
  
  # For testing
  YOU_TUBE_REFERENCE = '<iframe width="640" height="360" src="http://www.youtube.com/embed/pcOEsALr_Nc?feature=player_detailpage" frameborder="0" allowfullscreen></iframe>"'
  YOU_TUBE_REF_URL = 'http://www.youtube.com/embed/pcOEsALr_Nc?feature=player_detailpage'
  
  after_initialize :extract_url_from_source
  
  attr_accessible :title, :caption, :destination_url, :source,
                  :curator_id
  
  belongs_to :curator
  
  default_scope order('created_at DESC')
    
  validates_presence_of :curator_id
  
  validates_presence_of :title
  validates_presence_of :caption
  validates_presence_of :destination_url
  validates :source, :inclusion => { in: EMBEDDING_SOURCES }, 
                     :allow_blank => true
                     
private
  def extract_url_from_source
    if !self.source.nil?
      case self.source
      when YOU_TUBE
        if self.destination_url =~ /src=\"(http:\/\/www.youtube.com\/embed\/.*?)\"/
          self.destination_url = $1
        end
      # else... leave unchanged, we're not embedding, but linking directly somehow 
      end
    end
  end
end
