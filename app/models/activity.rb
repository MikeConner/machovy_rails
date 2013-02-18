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
  # What we're watching for the reports; translate these into titles in activity_title
  MONITORED_ACTIVITIES = ['BlogPost', 'Curator', 'Promotion']
  
  attr_accessible :activity_id, :activity_name, :description,
                  :user_id
  
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :activity_id
  validates :activity_name, :presence => true, 
                            :length => { maximum: 32 } 
                  
  # It logs the class name and id of the object related to the action
  #  e.g., "Order" 17 means they placed an order with id 17          
  def init_activity(obj)
    if obj.nil?
      logger.error("Activity #{self.id}; called init_activity with nil")
    else
      self.activity_name = obj.class.name
      self.activity_id = obj.id
    end
  end
  
  # Returns duration in seconds  
  # Currently this isn't used. The idea is you could update the same action to
  #   indicate duration. For instance, create the action when they click on a blog
  #   post, then update the same action when they click away. That's really hard to
  #   detect, though. More plausibly, if we blog posts were "paged," so that users had
  #   to click "next" or "read more," the action could be updated to indicate the
  #   time spent/degree of interest in the post.             
  def duration
    self.updated_at - self.created_at
  end
  
  # Curator -> Mentor
  def display_name
    'Curator' == self.activity_name ? 'Mentor' : self.activity_name
  end
  
  def activity_title
    if MONITORED_ACTIVITIES.include?(self.activity_name)
      case self.activity_name
      when 'BlogPost'
        BlogPost.find(self.activity_id).title
      when 'Curator'
        Curator.find(self.activity_id).name
      when 'Promotion'
        Promotion.find(self.activity_id).title
      else
        nil
      end
    else
      nil  
    end
    
    rescue
      'Not found'
  end
end
