class ChangeColumnNameTypeInPromoImageTable < ActiveRecord::Migration
  def up
    rename_column :promotion_images, :type, :mediatype

  end

  def down
    rename_column :promotion_images, :mediatype, :type

  end
end
