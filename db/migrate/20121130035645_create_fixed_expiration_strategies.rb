class CreateFixedExpirationStrategies < ActiveRecord::Migration
  def change
    create_table :fixed_expiration_strategies do |t|
      t.datetime :end_date, :null => false
      
      t.timestamps
    end
  end
end
