class Metro < ActiveRecord::Base
  attr_accessible :name
  has_many :promotions
  
end
