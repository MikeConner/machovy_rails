# == Schema Information
#
# Table name: curators
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  picture    :string(255)
#  bio        :text
#  twitter    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   A regional "character" or "personality" on the site, who writes blog posts and is responsible for local promotions
#
# USAGE
#   Created by admins; any ContentAdmin can write "as" a Curator. Curators are characters that have (perhaps fanciful)
#   bios and pictures. They also have real twitter accounts with which they can correspond with users.
#
#   Curators create blog posts, and then associate them with a set of promotions. Blog posts can be uncurated, if the
#   curator is deleted.
#
# NOTES AND WARNINGS
#
class Curator < ActiveRecord::Base
  # Could move to ApplicationHelpers with other such things if it's used anywhere else
  TWITTER_REGEX = /^@[A-Za-z0-9_]+$/
  MAX_TWITTER_LEN = 16 # 15 + @-character
  
  attr_accessible :bio, :name, :picture, :twitter

  # Curators own blog_posts, but not promotions
  has_many :blog_posts, :dependent => :nullify
  has_many :promotions, :through => :blog_posts
  
  mount_uploader :picture, ImageUploader
    
  # Note that the db-level indices are still case sensitive (in PG anyway)
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates :twitter, :presence => true,
                      :format => { with: TWITTER_REGEX },
                      :length => { maximum: MAX_TWITTER_LEN },
                      :uniqueness => { case_sensitive: false }
  validates_presence_of :bio
  
  validates_associated :blog_posts
end
