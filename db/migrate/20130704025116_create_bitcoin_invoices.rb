class CreateBitcoinInvoices < ActiveRecord::Migration
  def change
    create_table :bitcoin_invoices do |t|
      t.references :order
      t.decimal :price
      t.string :currency, :limit => BitcoinInvoice::CURRENCY_LEN, :default => 'USD'
      t.string :pos_data
      t.string :notification_key
      t.string :invoice_id
      t.string :invoice_url
      t.decimal :btc_price
      t.datetime :invoice_time
      t.datetime :expiration_time
      t.datetime :current_time

      t.timestamps
    end
  end
end
