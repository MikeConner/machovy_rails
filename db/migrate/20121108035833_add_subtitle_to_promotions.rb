class AddSubtitleToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :subtitle, :string
  end
end
