class CategoriesPromotions2 < ActiveRecord::Migration
  def up
    create_table 'categories_promotions' do |t|
      t.integer :category_id
      t.integer :promotion_id
    end
  end

  def down
    drop_table 'categories_promotions'
  end
end
