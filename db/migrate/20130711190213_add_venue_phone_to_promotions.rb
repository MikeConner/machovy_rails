class AddVenuePhoneToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :venue_phone, :string, :limit => User::PHONE_LEN
    add_column :promotions, :venue_url, :string
  end
end
