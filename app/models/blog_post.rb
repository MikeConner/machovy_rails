require 'utilities'

# == Schema Information
#
# Table name: blog_posts
#
#  id              :integer         not null, primary key
#  title           :string(255)
#  body            :text
#  curator_id      :integer
#  activation_date :datetime
#  weight          :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
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

  include Utilities
  
  DEFAULT_BLOG_WEIGHT = 10
  
  attr_accessible :body, :activation_date, :title, :weight, 
                  :curator_id, :promotion_ids
                  
  # foreign keys  
  belongs_to :curator
  
  # Curator will select a set of promotions to associate with this blog post
  has_and_belongs_to_many :promotions
  # ActiveRecord/PG bug requires this messy select statement when 'uniq' is enabled
  #   If uniq is not there, it will get multiple copies of the Metros
  #   If Promotions didn't have a default scope, all would be well, but as it is it doesn't recognize grid_weight
  #     hence the need to explicitly select it
  #   An alternative would be leave :select and :uniq off, allow it to get multiple metros,
  #     then call .uniq on the result. Works, but then all callers have to remember to do this.
  #     At least now the evil is localized
  has_many :metros, :through => :promotions, :select => "metros.*, grid_weight", :uniq => true
  
  # BlogPost.all returns list ordered by weight
  default_scope order(:weight)
  
  # Do not validate_presence_of curator_id; can be null if Curator is deleted
  # Does not require promotion associations
    
  validates_presence_of :title
  validates_presence_of :body
  validates_numericality_of :weight, { :only_integer => true, :greater_than => 0 }
  
  # WARNING! Not absolutely guaranteed to be called by Rails, but seems to work for current usage
  # after_initialize is recommended, but that doesn't fill anything on new, which is what we need for the create forms
  def initialize(*args)
    super
    
    self.weight = DEFAULT_BLOG_WEIGHT
    self.activation_date = Time.now
  end
  
  # DB scope can get lost when we're filtering and otherwise processing these as arrays
  def <=>(other)
    weight <=> other.weight
  end

  def displayable?
    self.activation_date.nil? or Time.now >= self.activation_date
  end

  def truncated_body(options = {})
    options.reverse_merge!(:length => 40)
    
    Utilities.html_truncator(body, options)
  end
end
