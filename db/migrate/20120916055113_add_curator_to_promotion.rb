class AddCuratorToPromotion < ActiveRecord::Migration
  def change
    add_column :promotions, :curator_id, :integer
  end
end
