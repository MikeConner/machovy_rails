class AddGeoToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :latitude, :decimal
    add_column :vendors, :longitude, :decimal
  end
end
