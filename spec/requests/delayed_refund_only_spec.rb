describe "SecureNet Certification script (ECheck refunds)" do
  let(:gateway) { ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY) }
  let(:common_options) { {:first_name => 'Jeffrey', :last_name => 'Bennett'} }
  
  subject { gateway }

  it { should respond_to(:echeck_purchase) }

  it "should point to the right urls" do
    gateway.test_url.should be == 'https://certify.securenet.com/API/gateway.svc/webHttp/'
    gateway.live_url.should be == 'https://gateway.securenet.com/api/Gateway.svc/webHttp/'
  end
  
  pending "ECheck sales" do
    before do
      @good = { :routing_number => '222371863', :account_number => '147852' }
      # Tests 73 and 74 can't pass immediately, since ACH transactions don't clear instantly, even with CloseBatch
      # You have to run securenet_certiication_echeck_spec, write down the two transaction ids it prints out, then wait a day or so until they settle
      # Set these transaction ids to the values printed out by securenet_certification_echeck_spec, then remove the pending and run this test
      @transaction_ids = ['110925536', '110925537']
      @bank = 'ESL FEDERAL CREDIT UNION'
    end

    describe "should pass test 73" do
      before do
        @response = gateway.echeck_credit(1100,  
                                          @transaction_ids[0],
                                          {:routing_number => @good[:routing_number], 
                                           :account_number => @good[:account_number],
                                           :bank_name => @bank,
                                           :certification_test => true}.merge(common_options))
        if !@response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_true
        @response.authorization.should_not be_blank
      end        
    end
    
    describe "should pass test 74" do
      before do
        @response = gateway.echeck_credit(600,  
                                          @transaction_ids[1],
                                          {:routing_number => @good[:routing_number], 
                                           :account_number => @good[:account_number],
                                           :bank_name => @bank,
                                           :certification_test => true}.merge(common_options))
        if !@response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_true
        @response.authorization.should_not be_blank
      end        
    end
  end  
end
