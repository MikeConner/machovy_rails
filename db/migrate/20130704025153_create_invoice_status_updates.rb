class CreateInvoiceStatusUpdates < ActiveRecord::Migration
  def change
    create_table :invoice_status_updates do |t|
      t.references :bitcoin_invoice
      t.string :status, :limit => InvoiceStatusUpdate::MAX_STATUS_LEN, :default => InvoiceStatusUpdate::NEW

      t.timestamps
    end
  end
end
