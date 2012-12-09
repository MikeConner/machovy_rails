class AddOrderIdToMachoBucks < ActiveRecord::Migration
  def change
    add_column :macho_bucks, :order_id, :integer
  end
end
