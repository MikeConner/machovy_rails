# == Schema Information
#
# Table name: activities
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  activity_name :string(32)      not null
#  activity_id   :integer         not null
#  description   :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Activity < ActiveRecord::Base
  MAX_NAME = 32
  
  attr_accessible :activity_id, :activity_name, :description,
                  :user_id
  
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :activity_id
  validates :activity_name, :presence => true, 
                            :length => { maximum: 32 } 
                            
  # Returns duration in seconds               
  def duration
    self.updated_at - self.created_at
  end
end
