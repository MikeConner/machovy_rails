class AddVenueNameToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :venue_name, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
  end
end
