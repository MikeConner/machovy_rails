class AddStrategyToPromotion < ActiveRecord::Migration
  def change
    add_column :promotions, :strategy_id, :integer
    add_column :promotions, :strategy_type, :string
  end
end
