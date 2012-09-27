class BlogPost < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  has_and_belongs_to_many :promotions

  attr_accessible :body, :curator_id, :metro_id, :posted_at, :title, :weight, :promotion_ids
  
  belongs_to :curator
  belongs_to :metro
  
  
end
