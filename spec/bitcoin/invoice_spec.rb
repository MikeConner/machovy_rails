require 'bitcoin_gateway'

# These tests require a running Bitpay server. Test invoice creation (and error conditions)
describe "Bitcoin Invoice" do
  let(:gateway) { BitcoinGateway.instance }
  let(:order) { FactoryGirl.create(:order) }
  
  # Set this so that the BitPay server talks back to the test server (otherwise test server will be on a random port)
  before { Capybara.server_port = 3000 }

  describe "Invalid invoice input data" do
    it "should require an order" do
      expect { gateway.create_invoice(nil, 250, 'USD') }.to raise_error(RuntimeError)
    end

    it "should require a valid amount" do
      [-1, 0, 'abc', nil].each do |amount|
        expect { gateway.create_invoice(order, amount, 'USD') }.to raise_error(RuntimeError)
      end
    end

    it "should require a valid currency" do
      [0, 'abc', nil].each do |currency|
        expect { gateway.create_invoice(order, 250, currency) }.to raise_error(RuntimeError)
      end
    end

    it "should not allow micro transactions" do
      expect { gateway.create_invoice(order, 1, 'USD') }.to raise_error(RuntimeError)
    end
  end
  
  describe "Valid invoice" do
    before { @invoice = gateway.create_invoice(order, order.total_cost, 'USD') }
    
    it "should be valid" do
      @invoice.should_not be_nil
      @invoice.class.name.should be == 'BitcoinInvoice'
      @invoice.should be_valid
      @invoice.invoice_id.should_not be_nil
      @invoice.invoice_url.should match(@invoice.notification_key)
      @invoice.price.should be == order.total_cost
      @invoice.currency.should be == 'USD'
      @invoice.notification_key.should_not be_nil
      @invoice.pos_data.should_not be_nil
      @invoice.btc_price.should be > 0
    end
    
    describe "should find it again" do
      before do
        sleep 15
        @data = gateway.get_invoice(@invoice.invoice_id)
      end
      
      it "should match" do
        @data['id'].should be == @invoice.invoice_id
        @data['price'].to_f.should be == order.total_cost
        @data['currency'].should be == 'USD'
        @data['status'].should be == InvoiceStatusUpdate::COMPLETE
        #BitcoinInvoice.find_by_invoice_id(@data['id']).invoice_status_updates.count.should be == 2
      end
    end
  end
  
  describe "Expired invoice" do
    let(:order) { FactoryGirl.create(:order, :amount => EXPIRED_STATUS_RESPONSE_AMT) }
    
    before { @invoice = gateway.create_invoice(order, order.total_cost, 'USD') }
    
    it "should be valid" do
      @invoice.should_not be_nil
      @invoice.class.name.should be == 'BitcoinInvoice'
      @invoice.should be_valid
      @invoice.invoice_id.should_not be_nil
      @invoice.invoice_url.should match(@invoice.notification_key)
      @invoice.price.should be == order.total_cost
      @invoice.currency.should be == 'USD'
      @invoice.notification_key.should_not be_nil
      @invoice.pos_data.should_not be_nil
      @invoice.btc_price.should be > 0
    end  
    
    describe "should find it again" do
      before do
        sleep 15
        @data = gateway.get_invoice(@invoice.invoice_id)
      end
      
      it "should match" do
        @data['id'].should be == @invoice.invoice_id
        @data['price'].to_f.should be == order.total_cost
        @data['currency'].should be == 'USD'
        @data['status'].should be == InvoiceStatusUpdate::EXPIRED
        #BitcoinInvoice.find_by_invoice_id(@data['id']).invoice_status_updates.count.should be == 2
      end
    end
  end

  describe "Invalid invoice" do
    let(:order) { FactoryGirl.create(:order, :amount => INVALID_STATUS_RESPONSE_AMT) }
    
    before { @invoice = gateway.create_invoice(order, order.total_cost, 'USD') }
    
    it "should be valid" do
      @invoice.should_not be_nil
      @invoice.class.name.should be == 'BitcoinInvoice'
      @invoice.should be_valid
      @invoice.invoice_id.should_not be_nil
      @invoice.invoice_url.should match(@invoice.notification_key)
      @invoice.price.should be == order.total_cost
      @invoice.currency.should be == 'USD'
      @invoice.notification_key.should_not be_nil
      @invoice.pos_data.should_not be_nil
      @invoice.btc_price.should be > 0
    end  

    describe "should find it again" do
      before do
        sleep 15
        @data = gateway.get_invoice(@invoice.invoice_id)
      end
      
      it "should match" do
        @data['id'].should be == @invoice.invoice_id
        @data['price'].to_f.should be == order.total_cost
        @data['currency'].should be == 'USD'
        @data['status'].should be == InvoiceStatusUpdate::INVALID
        #BitcoinInvoice.find_by_invoice_id(@data['id']).invoice_status_updates.count.should be == 2
      end
    end
  end
end