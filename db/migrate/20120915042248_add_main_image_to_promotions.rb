class AddMainImageToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :main_image, :string
  end
end
