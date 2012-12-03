class CreateMachoBucks < ActiveRecord::Migration
  def change
    create_table :macho_bucks do |t|
      t.decimal :amount, :null => false
      t.text :notes
      t.integer :admin_id
      t.references :user, :voucher

      t.timestamps
    end
    
    add_column :users, :total_macho_bucks, :decimal, :default => 0
  end
end
