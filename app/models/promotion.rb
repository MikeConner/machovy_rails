class Promotion < ActiveRecord::Base
  attr_accessible :description, :destination, :end, :grid_weight, :limitations, :metro_id, :price, :quantity, :retail_value, :revenue_shared, :start, :teaser_image, :title, :vendor_id, :voucher_instructions
end
