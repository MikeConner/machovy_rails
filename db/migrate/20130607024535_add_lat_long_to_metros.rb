class AddLatLongToMetros < ActiveRecord::Migration
  def change
    add_column :metros, :latitude, :decimal, :null => false, :default => 40.438169
    add_column :metros, :longitude, :decimal, :null => false, :default => -80.001875
  end
end
