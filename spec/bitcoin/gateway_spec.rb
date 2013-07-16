require 'bitcoin_gateway'

# These test basic connectivity to the bitpay server. It needs to be running for these to pass
describe "Bitcoin Gateway" do
  let(:gateway) { BitcoinGateway.instance }

  it "should connect" do
    gateway.connected?.should be_true
  end
  
  describe "Invalid connection" do
    let(:gateway) { InvalidGateway.instance }
    let(:order) { FactoryGirl.create(:order) }
    
    it "should not connect" do
      gateway.connected?.should be_false
    end
    
    it "requests should fail" do
      expect { gateway.create_invoice(order, 250, 'USD') }.to raise_error(RuntimeError)
    end
  end
end