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
#  metro_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   "News" content for the site, intended to catch readers' interest. Written by "characters" on the site (curators).
#
# USAGE
#
# NOTES AND WARNINGS
#
#  ??? How do we know which character wrote it? Show the curator info on the site somehow.
#
class BlogPost < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  attr_accessible :body :posted_at, :title, :weight
, :promotion_ids, :curator_id, :metro_id,
# foreign keys  
  belongs_to :curator
  belongs_to :metro
  
  has_and_belongs_to_many :promotions

  # BlogPost.all returns list ordered by weight
  default_scope order(:weight)
  
  validates_presence_of :curator_id
  validates_presence_of :metro_id
  
  validates_presence_of :title
  validates_presence_of :body
  validates_numericality_of :weight, { :only_integer => true, :greater_than => 0 }
end
