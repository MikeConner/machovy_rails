require 'machovy_securenet_gateway'

describe "SecureNet" do
  VALID_AMEX = '370000000000002'
  VALID_DISCOVER = '6011000000000012'
  VALID_MC = '5424000000000015'
  VALID_VISA = '4007000000027'
  CVV = '568'
  CVV_MC = '998'
  CVV_VISA = '999'
  BAD_MC = ['5105105105105100', '5555555555554444']
  BAD_VISA = ['4111111111111111', '4012888888881881']
  BAD_AMEX = ['378282246310005', '371449635398431']
  
  # Currently unsupported
  ROUTING = ['222371863', '307075259', '052000113']
  
  let(:gateway) { ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY) }
  
  subject { gateway }
  
  it "should be in test mode" do
    gateway.test?.should be_true
  end
  # cc = ActiveMerchant::Billing::CreditCard.new(:number => '5424000000000015', :verification_value => '998', :month => '3', :year => '2014', :first_name => 'Jeffrey', :last_name => 'Bennett')
  # r = g.authorize(1000, cc, :order_id => 17)
  describe "test charge" do
    before { @cc = cc = ActiveMerchant::Billing::CreditCard.new(:number => VALID_MC, 
                                                                :verification_value => CVV_MC, 
                                                                :month => '3', :year => '2014', 
                                                                :first_name => 'Jeffrey', 
                                                                :last_name => 'Bennett') }
                                                                
    it "card should be valid" do
      @cc.valid?.should be_true
      @cc.display_number.should be == 'XXXX-XXXX-XXXX-0015'
    end
    
    describe "it should process" do
      before do
        @response = gateway.authorize(1000, @cc, :order_id => 17)
        puts @response.message
      end
      
      it "should be valid" do
        @response.success?.should be_true
      end
    end
  end
end
