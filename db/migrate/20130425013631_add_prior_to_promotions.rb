class AddPriorToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :requires_prior_purchase, :boolean, :null => false, :default => false
  end
end
