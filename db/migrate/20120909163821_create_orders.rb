class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :description
      t.string :email
      t.decimal :amount
      t.string :stripe_card_token
      t.integer :promotion_id
      t.integer :user_id

      t.timestamps
    end
  end
end
