class RestorePromotionImages < ActiveRecord::Migration
 def change
	  drop_table :promotion_images  if table_exists?(:promotion_images) 
    create_table :promotion_images do |t|
      t.string :caption, :limit => 64
      t.string :media_type, :limit => 64
      t.string :slideshow_image
      t.string :remote_image_url
      t.references :promotion

      t.timestamps
    end
  end
end
