# == Schema Information
#
# Table name: ratings
#
#  id         :integer          not null, primary key
#  stars      :integer
#  comment    :text
#  idea_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# CHARTER
#   Star rating and comments on another user's Idea
#
# USAGE
#   Created and displayed on forum page
#
# NOTES AND WARNINGS
#
class Rating < ActiveRecord::Base
  DEFAULT_RATING = 5
  
  attr_accessible :stars, :comment,
                  :idea_id, :user_id
  after_initialize :default_rating
  
  belongs_to :idea
  belongs_to :user
  
  validates :stars, :presence => true,
                    :numericality => { only_integer: true, :in => [1, 5] }
  validate :users_cannot_rate_their_own_idea
  
private
  def users_cannot_rate_their_own_idea
    if idea.user.id == user.id
      self.errors.add(:base, I18n.t('rate_own_idea')) 
    end
  end
  
  def default_rating
    self.stars = DEFAULT_RATING if new_record?
  end
end
