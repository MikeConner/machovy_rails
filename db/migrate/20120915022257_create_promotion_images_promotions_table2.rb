class CreatePromotionImagesPromotionsTable2 < ActiveRecord::Migration
  def up
     create_table 'promotion_images_promotions' do |t|
        t.integer :promotion_id
        t.integer :promotion_image_id
      end
  end

  def down
    drop_table 'promotion_images_promotions'
  end
end
