#require 'machovy_securenet_gateway'

describe "SecureNet" do  
  let(:gateway) { ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY) }
  
  subject { gateway }
  
  it "should be in test mode" do
    gateway.test?.should be_true
  end
  # cc = ActiveMerchant::Billing::CreditCard.new(:number => '5424000000000015', :verification_value => '998', :month => '3', :year => '2014', :first_name => 'Jeffrey', :last_name => 'Bennett')
  # r = g.authorize(1000, cc, :order_id => 17)
  describe "test charge" do
    before { @cc = ActiveMerchant::Billing::CreditCard.new(:number => '5424180279791732', 
                                                           :verification_value => '998', 
                                                           :month => '3', :year => '2014', 
                                                           :first_name => 'Jeffrey', 
                                                           :last_name => 'Bennett') }
                                                                
    it "card should be valid" do
      @cc.valid?.should be_true
      @cc.display_number.should be == 'XXXX-XXXX-XXXX-1732'
    end
    
    describe "it should process" do
      before do
        billing = { :zip => '15237' }
         
        @response = gateway.authorize(Random.rand(10000) + 1000, @cc, :order_id => Utilities::generate_order, 
                                      :customer_ip => '65.55.58.201', 
                                      :email => 'jkb@claritech.com',
                                      :billing_address => billing)
        puts @response.message
      end
      
      it "should be valid" do
        @response.success?.should be_true
      end
    end
  end
end
