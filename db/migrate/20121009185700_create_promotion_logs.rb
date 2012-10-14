class CreatePromotionLogs < ActiveRecord::Migration
  def change
    create_table :promotion_logs do |t|
      t.references :promotion
      t.string :status, :null => false, :limit => Promotion::MAX_STR_LEN
      t.text :comment

      t.timestamps
    end
  end
end
