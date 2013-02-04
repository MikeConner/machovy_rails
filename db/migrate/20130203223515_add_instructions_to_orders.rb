class AddInstructionsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :pickup_notes, :string
  end
end
