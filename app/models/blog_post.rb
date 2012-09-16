class BlogPost < ActiveRecord::Base
  attr_accessible :body, :curator_id, :metro_id, :posted_at, :title, :weight
  
  belongs_to :curator
  belongs_to :metro
  
  
end
