class AddSuspendFlagToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :suspended, :boolean, :default => false, :null => false
  end
end
