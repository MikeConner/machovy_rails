class AddMinMaxQuantityToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :min_per_customer, :integer, :null => false, :default => 1
    add_column :promotions, :max_per_customer, :integer, :null => false, :default => Promotion::UNLIMITED
  end
end
