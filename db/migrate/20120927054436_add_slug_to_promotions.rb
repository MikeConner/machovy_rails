class AddSlugToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :slug, :string
    add_index :promotions, :slug
  end
end
