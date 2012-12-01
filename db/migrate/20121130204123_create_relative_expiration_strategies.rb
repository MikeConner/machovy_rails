class CreateRelativeExpirationStrategies < ActiveRecord::Migration
  def change
    create_table :relative_expiration_strategies do |t|
      t.integer :period_days, :null => false

      t.timestamps
    end
  end
end
