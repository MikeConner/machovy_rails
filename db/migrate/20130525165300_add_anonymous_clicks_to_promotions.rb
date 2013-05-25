class AddAnonymousClicksToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :anonymous_clicks, :integer, :null => false, :default => 0
  end
end
