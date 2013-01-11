require 'machovy_securenet_gateway'
require 'utilities'

describe "SecureNet Certification script (ECheck)" do
  let(:gateway) { ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY) }
  let(:common_options) { {:first_name => 'Jeffrey', :last_name => 'Bennett'} }
  
  subject { gateway }

  it { should respond_to(:echeck_purchase) }

  it "should point to the right urls" do
    gateway.test_url.should be == 'https://certify.securenet.com/API/gateway.svc/webHttp/'
    gateway.live_url.should be == 'https://gateway.securenet.com/api/Gateway.svc/webHttp/'
  end
  
  describe "ECheck sales" do
    before do
      @good = { :routing_number => '222371863', :account_number => '147852' }
      @bad = { :routing_number => '222371862', :account_number => '1477895' }
      @bank = 'ESL FEDERAL CREDIT UNION'
    end

    describe "should pass test 69" do
      before do
        @response = gateway.echeck_purchase(1100,  
                                            {:routing_number => @good[:routing_number], 
                                             :account_number => @good[:account_number],
                                             :bank_name => @bank}.merge(common_options))
        @transaction_id = @response.authorization
        if !@response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_true
        @response.authorization.should_not be_blank
      end
    
      describe "should pass test 72" do
        before do
          @response = gateway.echeck_void(1100,
                                          @transaction_id,  
                                          {:routing_number => @good[:routing_number], 
                                           :account_number => @good[:account_number],
                                           :bank_name => @bank}.merge(common_options))
          @transaction_id = @response.authorization
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
 
    describe "should pass test 70" do
      before do
        @response = gateway.echeck_purchase(2100,  
                                            {:routing_number => @good[:routing_number], 
                                             :account_number => @bad[:account_number],
                                             :bank_name => @bank}.merge(common_options))
        @transaction_id = @response.authorization
        if @response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_false
        @response.authorization.should_not be_blank
        @response.params['response_reason_text'].should be == 'Declined  INVALID ACCOUNT'
      end
    end

    describe "should pass test 71" do
      before do
        @response = gateway.echeck_purchase(2100,  
                                            {:routing_number => @bad[:routing_number], 
                                             :account_number => @good[:account_number],
                                             :bank_name => @bank}.merge(common_options))
        @transaction_id = @response.authorization
        if @response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_false
        @response.authorization.should_not be_blank
        @response.params['response_reason_text'].should be == 'VALID 9-DIGIT BANK ABA ROUTING NUMBER IS REQUIRED'
      end
    end
    
    describe "credit tests" do
      before do
        @response = gateway.echeck_purchase(1100,  
                                            {:routing_number => @good[:routing_number], 
                                             :account_number => @good[:account_number],
                                             :bank_name => @bank,
                                             :certification_test => true}.merge(common_options))
        @transaction_id = @response.authorization
        if @response.success?
          puts @response.message
          puts @response.inspect
        end
      end
      
      it "should return the correct response" do
        @response.success?.should be_true
        @response.authorization.should_not be_blank
      end
      
      describe "should pass test 73" do
        before do
          @response = gateway.close_batch
          if @response.success?
            puts @response.message
            puts @response.inspect
          end
            
          @response = gateway.echeck_credit(600,  
                                            @transaction_id,
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
          @response = gateway.close_batch
          if @response.success?
            puts @response.message
            puts @response.inspect
          end
            
          @response = gateway.echeck_credit(600,  
                                            @transaction_id,
                                            {:routing_number => @good[:routing_number], 
                                             :account_number => @good[:account_number],
                                             :bank_name => @bank,
                                             :certification_test => true}.merge(common_options))
          @transaction_id = @response.authorization
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
end
