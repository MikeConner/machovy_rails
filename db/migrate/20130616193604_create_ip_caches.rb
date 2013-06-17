class CreateIpCaches < ActiveRecord::Migration
  def change
    create_table :ip_caches do |t|
      t.string :ip, :null => false, :limit => 16
      t.decimal :latitude, :null => false
      t.decimal :longitude, :null => false

      t.timestamps
    end
    
    add_index :ip_caches, :ip, :unique => true
  end
end
