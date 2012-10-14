class AddPromotionType < ActiveRecord::Migration
  def up
    # 32 down to 16
    change_column :promotions, :status, :string, :limit => 16, :null => false, :default => Promotion::PROPOSED
    # remove default (actually a mistake, so don't want to undo it)
    change_column :promotions, :description, :string, :default => nil
    change_column :promotions, :destination, :string, :default => nil
    add_column :promotions, :promotion_type, :string, :limit => 16, :null => false, :default => Promotion::LOCAL_DEAL
  end

  def down
    change_column :promotions, :status, :string, :limit => 32
    remove_column :promotions, :promotion_type
  end
end
