class AddSlugToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :slug, :string
    add_index :vouchers, :slug
  end
end
