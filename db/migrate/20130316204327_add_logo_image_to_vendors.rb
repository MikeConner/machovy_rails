class AddLogoImageToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :logo_image, :string
  end
end
