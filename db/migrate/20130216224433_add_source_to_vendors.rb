class AddSourceToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :source, :string
  end
end
