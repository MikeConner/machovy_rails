class Curator < ActiveRecord::Base
  attr_accessible :bio, :metro_id, :name, :picture, :twitter, :user_id
  belongs_to :user
  has_many :blog_posts
  has_many :promotions
  belongs_to :metro
  
  mount_uploader :picture, ImageUploader
  
end
