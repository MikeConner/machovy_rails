class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount, :null => false
      t.integer :check_number, :null => false
      t.date :check_date, :null => false
      t.text :notes
      t.references :vendor, :null => false
      
      t.timestamps
    end
    
    add_column :vouchers, :payment_id, :integer
  end
end
