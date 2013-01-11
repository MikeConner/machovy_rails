class RemoveStripe < ActiveRecord::Migration
  def up
    drop_table :stripe_logs
    remove_column :orders, :stripe_card_token
    remove_column :orders, :charge_id
    remove_column :gift_certificates, :charge_id
    remove_column :users, :stripe_id
    add_column :orders, :transaction_id, :string, :limit => 15
    add_column :orders, :first_name, :string, :limit => User::MAX_FIRST_NAME_LEN
    add_column :orders, :last_name, :string, :limit => User::MAX_LAST_NAME_LEN
    add_column :gift_certificates, :transaction_id, :string, :limit => 15
    add_column :gift_certificates, :first_name, :string, :limit => User::MAX_FIRST_NAME_LEN
    add_column :gift_certificates, :last_name, :string, :limit => User::MAX_LAST_NAME_LEN
    add_column :users, :customer_id, :string, :limit => User::CUSTOMER_ID_LEN
  end

  def down
    create_table :stripe_logs do |t|
      t.string :event_id, :limit => 40 # StripeLog::MAX_STR_LEN -- not here when model deleted!
      t.string :event_type, :limit => 40
      t.boolean :livemode
      t.text :event
      t.references :user

      t.timestamps
    end
    
    add_column :orders, :stripe_card_token, :string
    add_column :orders, :charge_id, :string
    add_column :gift_certificates, :charge_id, :string
    add_column :users, :stripe_id, :string
    remove_column :orders, :transaction_id
    remove_column :orders, :first_name
    remove_column :orders, :last_name
    remove_column :gift_certificates, :transaction_id
    remove_column :gift_certificates, :first_name
    remove_column :gift_certificates, :last_name
    remove_column :users, :customer_id
  end
end
