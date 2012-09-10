class Vendor < ActiveRecord::Base
  attr_accessible :address_1, :address_2, :city, :fbook, :name, :phone, :state, :url, :zip
  has_many :promotions
  has_many :metros, :through => :promotions
end
