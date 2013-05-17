class AddNotesToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :notes, :string
  end
end
