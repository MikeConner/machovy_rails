class AddVoucherDelay < ActiveRecord::Migration
  def change
    add_column :fixed_expiration_strategies, :delay_hours, :integer, :default => 0, :null => false
    add_column :relative_expiration_strategies, :delay_hours, :integer, :default => 0, :null => false
    add_column :vouchers, :delay_hours, :integer
  end
end
