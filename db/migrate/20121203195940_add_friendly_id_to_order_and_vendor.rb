class AddFriendlyIdToOrderAndVendor < ActiveRecord::Migration
  def change
    add_column :orders, :slug, :string
    add_column :vendors, :slug, :string
  end
end
