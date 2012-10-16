class RestorePromotionImages < ActiveRecord::Migration
 def change
    create_table :promotion_images do |t|
      t.string :caption, :limit => PromotionImage::MAX_CAPTION_LEN
      t.string :media_type, :limit => PromotionImage::MAX_TYPE_LEN
      t.string :slideshow_image
      t.string :remote_image_url
      t.references :promotion

      t.timestamps
    end
  end
end
