class CreateGiftCertificates < ActiveRecord::Migration
  def change
    create_table :gift_certificates do |t|
      t.references :user
      t.integer :amount, :null => false
      t.string :email, :null => false
      t.string :charge_id, :null => false
      t.boolean :pending, :default => true

      t.timestamps
    end
  end
end
