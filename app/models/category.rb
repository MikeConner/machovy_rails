class Category < ActiveRecord::Base
  attr_accessible :name, :status
  has_and_belongs_to_many :promotions
end
