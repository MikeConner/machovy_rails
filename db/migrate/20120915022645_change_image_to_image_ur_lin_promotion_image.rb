class ChangeImageToImageUrLinPromotionImage < ActiveRecord::Migration
  def up
    rename_column :promotion_images, :image, :imageurl
  end

  def down
    rename_column :promotion_images, :imageurl, :image

  end
end
