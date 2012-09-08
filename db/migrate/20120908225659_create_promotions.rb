class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :title
      t.string :description
      t.string :limitations
      t.string :voucher_instructions
      t.string :teaser_image
      t.decimal :retail_value
      t.decimal :price
      t.decimal :revenue_shared
      t.integer :quantity
      t.datetime :start
      t.datetime :end
      t.integer :grid_weight
      t.string :destination
      t.integer :metro_id
      t.integer :vendor_id

      t.timestamps
    end
  end
end
