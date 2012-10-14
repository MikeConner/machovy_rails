class AddUuidIndexToVouchers < ActiveRecord::Migration
  def change
    add_index :vouchers, :uuid, :unique => true 
  end
end
