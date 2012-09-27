class BlogPost < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  attr_accessible :body, :curator_id, :metro_id, :posted_at, :title, :weight
  
  belongs_to :curator
  belongs_to :metro
  
  
end
