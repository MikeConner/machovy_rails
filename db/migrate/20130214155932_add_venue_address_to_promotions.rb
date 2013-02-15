class AddVenueAddressToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :venue_address, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :promotions, :venue_city, :string, :limit => ApplicationHelper::MAX_ADDRESS_LEN
    add_column :promotions, :venue_state, :string, :limit => ApplicationHelper::STATE_LEN
    add_column :promotions, :venue_zipcode, :string, :limit => ApplicationHelper::ZIP_PLUS4_LEN
    add_column :promotions, :latitude, :decimal
    add_column :promotions, :longitude, :decimal
  end
end
