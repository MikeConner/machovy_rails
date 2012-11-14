# == Schema Information
#
# Table name: ideas
#
#  id         :integer         not null, primary key
#  name       :string(16)
#  title      :string(40)
#  content    :text
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# CHARTER
#   Feedback generated by a Machovy user. Idea for improvement (of website, business model, etc.)
#
# USAGE
#   Created and displayed on forum page
#
# NOTES AND WARNINGS
#
class Idea < ActiveRecord::Base
  MAX_NAME_LEN = 16
  MAX_TITLE_LEN = 40
  
  attr_accessible :content, :name, :title,
                  :user_id
  
  belongs_to :user
  has_many :ratings, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :content
  
  validates_presence_of :user_id

  validate :users_can_only_rate_an_idea_once
  
  validates_associated :ratings
  
  # This is used for pagination; it shows 30/page by default
  def self.per_page
    7
  end
  
  def average_rating
    if 0 == self.ratings.count
      nil
    else
      sum = 0.0
      self.ratings.each do |rating|
        sum += rating.stars
      end
      
      sum / self.ratings.count
    end
  end
 
  def num_comments
    total = 0
    self.ratings.each do |rating|
      if !rating.comment.nil?
        total += 1
      end
    end
    
    total
  end
  
  def <=>(other)
    # if both are nil, no way to sort
    if other.average_rating.nil? and self.average_rating.nil?
      0
    else
      # if only 1 is nil, put the rated one first
      if other.average_rating.nil?
        -1
      elsif self.average_rating.nil?
        1
      else
        # if both have values, sort descending
        other.average_rating <=> self.average_rating
      end
    end
  end
  
private
  def users_can_only_rate_an_idea_once     
    validate_uniqueness_of_in_memory(ratings, [:user_id, :id], 'You already rated this idea')   
  end

  def validate_uniqueness_of_in_memory(collection, attrs, message) 
    hashes = collection.inject({}) do |hash, record| 
      key = attrs.map {|a| record.send(a).to_s }.join 
      if key.blank? || record.marked_for_destruction? 
        key = record.object_id 
      end 
      hash[key] = record unless hash[key] 
      hash 
    end 
    if collection.length > hashes.length 
      self.errors.add(:base, message) 
    end 
  end 
end