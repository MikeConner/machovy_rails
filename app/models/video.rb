# == Schema Information
#
# Table name: videos
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  destination :string(255)
#  active      :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

# CHARTER
#   Represent a video (multimedia format)
#
# USAGE
#
# NOTES AND WARNINGS
# ??? Is this used? What does destination mean? How is active used? Format?
# ??? Shouldn't this be tied to something? Or is it just a general video about the site, not part of a promotion?
#  (e.g., reality show trailer :-)
#
class Video < ActiveRecord::Base
  attr_accessible :active, :destination, :name
  
  validates :active, :presence => true,
                     :inclusion => { in: [true, false] }
  validates_presence_of :name
  validates_presence_of :destination
end
