class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :url
      t.string :fbook
      t.string :phone
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
  end
end
