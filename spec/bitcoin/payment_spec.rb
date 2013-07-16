require 'bitcoin_gateway'

# These tests require a running Bitpay server. Test the payment "frame" api. Also have to be running a worker thread on BitPay
# Cannot be running anything else on port 3000!
describe "Bitcoin Invoice" do
  let(:gateway) { BitcoinGateway.instance }
  let(:order) { FactoryGirl.create(:order) }
  let(:invoice) { gateway.create_invoice(order, order.total_cost, 'USD') }  
  
  # Set this so that the BitPay server talks back to the test server (otherwise test server will be on a random port)
  before { Capybara.server_port = 3000 }
  
  subject { page }
  
  describe "Valid invoice" do
    before do
       # Allow visiting external urls 
      Capybara.current_driver = :selenium
      visit invoice.invoice_url
    end
    
    it { should have_content('Payment frame') }
    it { should have_content(invoice.notification_key) }
    it { should have_content(invoice.btc_price.round(3)) }    
  end
end