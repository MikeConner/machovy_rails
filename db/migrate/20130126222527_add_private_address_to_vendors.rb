class AddPrivateAddressToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :private_address, :boolean, :default => false
  end
end
