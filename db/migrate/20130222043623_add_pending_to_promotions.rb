class AddPendingToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :pending, :boolean, :default => false, :null => false
  end
end
