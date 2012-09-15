class ChangeDestinationColumnNameToImageLocation < ActiveRecord::Migration
  def up
    rename_column :promotion_images, :destination, :image
  end

  def down
    rename_column :promotion_images, :image, :destination

  end
end
