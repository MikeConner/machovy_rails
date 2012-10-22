class AddStripeInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string
    
    add_column :orders, :charge_id, :string
  end
end
