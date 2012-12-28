class CreateProductStrategies < ActiveRecord::Migration
  def change
    create_table :product_strategies do |t|
      t.boolean :delivery, :default => true
      t.string :sku, :limit => ApplicationHelper::MAX_SKU_LEN

      t.timestamps
    end
    
    add_column :orders, :name, :string, :limit => User::MAX_FIRST_NAME_LEN + User::MAX_LAST_NAME_LEN + 1
    add_column :orders, :address_1, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :orders, :address_2, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :orders, :city, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :orders, :state, :string, :limit => ApplicationHelper::STATE_LEN
    add_column :orders, :zipcode, :string, :limit => ApplicationHelper::ZIP_PLUS4_LEN
  end
end
