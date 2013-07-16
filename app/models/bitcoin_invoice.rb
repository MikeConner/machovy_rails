# == Schema Information
#
# Table name: bitcoin_invoices
#
#  id               :integer         not null, primary key
#  order_id         :integer
#  price            :decimal(, )
#  currency         :string(3)       default("USD")
#  pos_data         :string(255)
#  notification_key :string(255)
#  invoice_id       :string(255)
#  invoice_url      :string(255)
#  btc_price        :decimal(, )
#  invoice_time     :datetime
#  expiration_time  :datetime
#  current_time     :datetime
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class BitcoinInvoice < ActiveRecord::Base
  includes ApplicationHelper
  
  CURRENCY_LEN = 3
  CURRENCIES = ['USD', 'EUR', 'GBP', 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'HKD', 'HRK', 'HUF', 'IDR',
                'ILS', 'INR', 'JPY', 'KRW', 'LTL', 'LVL', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'RUB',
                'SEK', 'SGD', 'THB', 'TRY', 'ZAR']
  
  attr_accessible :invoice_id, :price, :currency, :current_time, :expiration_time, :invoice_time, :invoice_url, :notification_key, :pos_data, :btc_price,
                  :order_id

  belongs_to :order
  has_many :invoice_status_updates, :dependent => :destroy
  
  validates_presence_of :invoice_id
  validates_presence_of :current_time
  validates_presence_of :expiration_time
  validates_presence_of :invoice_time
  validates_presence_of :notification_key
  validates_numericality_of :price
  validates_numericality_of :btc_price
  # invoice_url doesn't validate in test; well, it's coming from the server, not users
  #validates :invoice_url, :format => { :with => ApplicationHelper::URL_REGEX }
  validates :currency, :presence => true, 
                       :inclusion => { :in => CURRENCIES },
                       :length => { :is => CURRENCY_LEN }
                       
  def invoice_status
    latest = self.invoice_status_updates.order('created_at DESC')
    if latest.empty?
      InvoiceStatusUpdate::NEW
    else
      latest.first.status
    end
  end
end
