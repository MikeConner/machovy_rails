class AddQuantityToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :quantity, :integer, :null => false, :default => 1
  end
end
