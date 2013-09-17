class CreateExternalCoupons < ActiveRecord::Migration
  def change
    create_table :external_coupons do |t|
      t.references :metro
      t.string :name, :null => false
      t.string :address_1
      t.string :address_2
      t.string :deal_url, :null => false
      t.string :store_url
      t.string :source
      t.string :phone, :limit => User::PHONE_LEN
      t.string :city, :limit => ApplicationHelper::MAX_ADDRESS_LEN
      t.string :state, :limit => ApplicationHelper::STATE_LEN
      t.string :zip, :limit => ApplicationHelper::ZIP_PLUS4_LEN
      t.integer :deal_id, :null => false
      t.string :user_name
      t.integer :user_id
      t.string :title, :null => false
      t.text :disclaimer
      t.text :deal_info
      t.date :expiration_date, :null => false
      t.datetime :post_date
      t.string :small_image_url, :null => false
      t.string :big_image_url, :null => false
      t.string :logo_url
      t.integer :deal_type_id
      t.integer :category_id
      t.integer :subcategory_id
      t.decimal :distance
      t.decimal :original_price
      t.decimal :deal_price
      t.decimal :deal_savings
      t.decimal :deal_discount
      t.string :slug
      
      t.timestamps
    end
    
    add_index :external_coupons, :deal_id, :unique => true
    add_index :external_coupons, :slug
  end
end
