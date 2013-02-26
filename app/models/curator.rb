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
#  slug       :string(255)
#  title      :string(48)
#  weight     :integer
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
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  # Could move to ApplicationHelpers with other such things if it's used anywhere else
  TWITTER_REGEX = /^@[A-Za-z0-9_]+$/
  MAX_TWITTER_LEN = 16 # 15 + @-character
  MAX_TITLE_LEN = 48
  MAX_POSTS = 4
  DEFAULT_MENTOR_WEIGHT = 10
  
  after_initialize :init_weight
  
  # Title means the curator's "specialty" (e.g., Style Contributor)
  attr_accessible :bio, :name, :picture, :remote_picture_url, :twitter, :title, :weight

  # Curators own blog_posts, but not promotions
  has_many :blog_posts, :dependent => :nullify
  has_many :videos, :dependent => :nullify
  has_many :promotions, :through => :blog_posts
  
  mount_uploader :picture, ImageUploader
      
  # Note that the db-level indices are still case sensitive (in PG anyway)
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates :title, :presence => true,
                    :length => { maximum: MAX_TITLE_LEN }
  validates :twitter, :presence => true,
                      :format => { with: TWITTER_REGEX },
                      :length => { maximum: MAX_TWITTER_LEN },
                      :uniqueness => { case_sensitive: false }
  validates_presence_of :bio
  validates_numericality_of :weight, { :only_integer => true, :greater_than => 0 }
  
  validates_associated :blog_posts

  def recent_posts
    #@posts = blog_posts.find(:all, :order => 'created_at DESC')
    # Shouldn't need the find now that we removed the default scope
    @posts = blog_posts.order('created_at DESC')
    if @posts.length > MAX_POSTS
      @posts = @posts[0, MAX_POSTS]
    end
    
    @posts
  end
  
  def twitter_path
    "http://www.twitter.com/#{self.twitter[1, self.twitter.length - 1]}"
  end
  
  def blog_posts_for(promotion)
    blog_posts.select { |post| post.promotion_ids.include?(promotion.id) }
  end
  
private
  def init_weight
    self.weight = DEFAULT_MENTOR_WEIGHT if new_record?
  end
end
