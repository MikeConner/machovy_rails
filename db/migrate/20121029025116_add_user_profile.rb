class AddUserProfile < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, :limit => User::MAX_FIRST_NAME
    add_column :users, :last_name, :string, :limit => User::MAX_LAST_NAME
    add_column :users, :address_1, :string, :limit => User::MAX_ADDRESS
    add_column :users, :address_2, :string, :limit => User::MAX_ADDRESS
    add_column :users, :city, :string, :limit => User::MAX_ADDRESS
    add_column :users, :state, :string, :limit => User::STATE_LEN
    add_column :users, :zipcode, :string, :limit => User::ZIPCODE_LEN
    add_column :users, :phone, :string, :limit => User::PHONE_LEN
    add_column :users, :optin, :boolean, :null => false, :default => false
    
    create_table :categories_users, :id => false do |t|
      t.references :category, :user
    end
    
    add_index :categories_users, [:category_id, :user_id], :unique => true
  end
end
