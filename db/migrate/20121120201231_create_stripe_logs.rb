class CreateStripeLogs < ActiveRecord::Migration
  def change
    create_table :stripe_logs do |t|
      t.string :event_id, :limit => StripeLog::MAX_STR_LEN
      t.string :event_type, :limit => StripeLog::MAX_STR_LEN
      t.boolean :livemode
      t.text :event
      t.references :user

      t.timestamps
    end
  end
end
