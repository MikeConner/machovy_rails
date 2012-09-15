class CreatePromotionImages < ActiveRecord::Migration
  def change
    create_table :promotion_images do |t|
      t.string :name
      t.string :destination
      t.string :type

      t.timestamps
    end
  end
end
