class RenameSlideshowImage < ActiveRecord::Migration
  def change
    rename_column :promotion_images, :remote_image_url, :remote_slideshow_image_url
  end
end
