class AddProcessingFlagsToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :teaser_image_processing, :boolean
    add_column :promotions, :main_image_processing, :boolean
    add_column :promotion_images, :slideshow_image_processing, :boolean
  end
end
