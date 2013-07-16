require 'bitcoin_gateway'

# These tests should pass if there is NO bitpay server running
describe "Bitcoin Gateway" do
  let(:gateway) { BitcoinGateway.instance }

  it "should not connect" do
    gateway.connected?.should be_false
  end
  
  describe "try an order" do
    let(:order) { FactoryGirl.create(:order) }
  
    it "requests should fail" do
      expect { gateway.create_invoice(order, 250, 'USD') }.to raise_error(RuntimeError)
    end
  end
end