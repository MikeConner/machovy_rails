class AddUserProfile < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, :limit => User::MAX_FIRST_NAME_LEN
    add_column :users, :last_name, :string, :limit => User::MAX_LAST_NAME_LEN
    add_column :users, :address_1, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :users, :address_2, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :users, :city, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :users, :state, :string, :limit => ApplicationHelper::STATE_LEN
    add_column :users, :zipcode, :string, :limit => ApplicationHelper::ZIPCODE_LEN
    add_column :users, :phone, :string, :limit => User::PHONE_LEN
    add_column :users, :optin, :boolean, :null => false, :default => false
    
    create_table :categories_users, :id => false do |t|
      t.references :category, :user
    end
    
    add_index :categories_users, [:category_id, :user_id], :unique => true
  end
end
