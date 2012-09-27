# == Schema Information
#
# Table name: curators
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  picture    :string(255)
#  bio        :text
#  twitter    :string(255)
#  user_id    :integer
#  metro_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   A regional "character" or "personality" on the site, who writes blog posts and is responsible for local promotions
#
# USAGE
#
# NOTES AND WARNINGS
#  ??? Are we really going to keep up with this on Twitter? Are we going to be corresponding with customers?
#  It's associated with a user, but users don't have curators. Right now the only Role defined is "SuperAdmin"
#  ??? Do we have a "Curator" or "Avatar" role? User looks like it's geared toward real customers (e.g., IP capturing)
#  Well, I suppose if this grows and gets really big, we'd want to keep track of what the Curators are doing as
#    users, so it does make sense; we need a role, though. And it should validate that the user is a Curator.
#  ??? Can a user have several Curator characters? I think we need an association going the other way in any case.
# 
# TODO Need uniqueness index on name and twitter
#
class Curator < ActiveRecord::Base
  TWITTER_REGEX = /^@[A-Za-z0-9_]+$/
  MAX_TWITTER_LEN = 16 # 15 + @-character
  
  attr_accessible :bio, :metro_id, :name, :picture, :twitter, :user_id

  # Foreign keys  
  belongs_to :user
  belongs_to :metro

  has_many :blog_posts
  has_many :promotions
  
  mount_uploader :picture, ImageUploader
  
  validates_presence_of :user_id
  validates_presence_of :metro_id
  
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates :twitter, :presence => true,
                      :format => { with: TWITTER_REGEX },
                      :length => { maximum: MAX_TWITTER_LEN },
                      :uniqueness => { case_sensitive: false }
  validates_presence_of :bio
  validates_associated :blog_posts
end
