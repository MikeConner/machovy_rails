class AddMetroToUsers < ActiveRecord::Migration
  def change
    add_column :users, :metro_id, :integer
  end
end
