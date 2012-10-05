# == Schema Information
#
# Table name: blog_posts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :text
#  curator_id :integer
#  posted_at  :datetime
#  weight     :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  slug       :string(255)
#

# CHARTER
#   "News" content for the site, intended to catch readers' interest. Written by "characters" on the site (curators).
#
# USAGE
#   Created by Curators (User with "ContentAdmin" role writing as a particular Curator). Curator selects a set of 
# related promotions, and blog posts can then be filtered/selected based on what promotions are currently being displayed.
#
#   If you delete a curator, the foreign key here will be nulled out (without affecting promotion associations)
# 
# NOTES AND WARNINGS
#
class BlogPost < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  attr_accessible :body, :posted_at, :title, :weight, 
                  :curator_id, :promotion_ids
                  
  # foreign keys  
  belongs_to :curator
  
  # Curator will select a set of promotions to associate with this blog post
  has_and_belongs_to_many :promotions, :uniq => true

  # BlogPost.all returns list ordered by weight
  default_scope order(:weight)
  
  # Do not validate_presence_of curator_id; can be null if Curator is deleted
  # Does not require promotion associations
    
  validates_presence_of :title
  validates_presence_of :body
  validates_numericality_of :weight, { :only_integer => true, :greater_than => 0 }
end
