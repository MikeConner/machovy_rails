class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :uuid
      t.datetime :redemption_date
      t.string :status
      t.text :notes
      t.datetime :expiration_date
      t.datetime :issue_date
      t.integer :promotion_id
      t.integer :order_id
      t.integer :user_id

      t.timestamps
    end
  end
end
