#require 'machovy_securenet_gateway'
require 'utilities'

describe "SecureNet Certification script (master card)" do
  let(:gateway) { ActiveMerchant::Billing::MachovySecureNetGateway.new(:login => SECURENET_ID, :password => SECURENET_KEY) }
  let(:common_options) { {:month => '4', :year => '2014', :first_name => 'Jeffrey', :last_name => 'Bennett'} }
  
  subject { gateway }

  it "should point to the right urls" do
    gateway.test_url.should be == 'https://certify.securenet.com/API/gateway.svc/webHttp/'
    gateway.live_url.should be == 'https://gateway.securenet.com/api/Gateway.svc/webHttp/'
  end
  
  it "should have the proper methods" do
    gateway.should respond_to(:authorize)
    gateway.should respond_to(:purchase)
    gateway.should respond_to(:capture)
    gateway.should respond_to(:credit)
    gateway.should respond_to(:void)
  end
  
  describe "Mastercard sales" do
    before do
      @credit_cards = [{:number => '5424 1802 7979 1732', :verification_value => '998', :amount => 1100, :avs => '20850'},
                       {:number => '5405 0101 0000 0016', :verification_value => '998', :amount => 1100, :avs => '20704'},
                       {:number => '5149 6122 2222 2229', :verification_value => '996', :amount => 1200, :avs => '20850'},
                       {:number => '5526 3990 0064 8568', :verification_value => '996', :amount => 2100, :avs => '20704'}]
      @bad_card = {:number => '5567 0640 0000 0000', :verification_value => '998', :amount => 3100, :avs => '20704'}
    end

    describe "should pass test 18" do
      before {
        @card = ActiveMerchant::Billing::CreditCard.new({:number => @credit_cards[0][:number].gsub!(' ', ''),
                                                         :verification_value => @credit_cards[0][:verification_value]}.merge(common_options))
        @address = { :zip =>  @credit_cards[0][:avs] }
      }
      
      it "should be a valid card" do
        @card.valid?.should be_true
      end  
      
      describe "authorize" do
        before do
          @response = gateway.authorize(@credit_cards[0][:amount], @card, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true, # set Physical goods flag 
                                        :billing_address => @address)
          @transaction_id = @response.authorization
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'M'
          @response.cvv_result['code'].should be == 'M'
          @response.cvv_result['message'].should be == 'Match'
          @response.authorization.should_not be_blank
        end
        
        describe "capture (test 22)" do
          before do
            @response = gateway.capture(@credit_cards[0][:amount], @card, 
                                        @transaction_id,
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'M'
            @response.cvv_result['code'].should be == 'M'
            @response.cvv_result['message'].should be == 'Match'
            @response.authorization.should_not be_blank
          end
        end            
      end
      
      describe "authorize and capture (test 26)" do
        before do
          @response = gateway.purchase(@credit_cards[0][:amount], @card, 
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true, # set Physical goods flag 
                                       :billing_address => @address)
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'M'
          @response.cvv_result['code'].should be == 'M'
          @response.cvv_result['message'].should be == 'Match'
          @response.authorization.should_not be_blank
        end
      end    
    end    

    describe "should pass test 19" do
      before {
        @card = ActiveMerchant::Billing::CreditCard.new({:number => @credit_cards[1][:number].gsub!(' ', ''),
                                                         :verification_value => @credit_cards[1][:verification_value]}.merge(common_options))
      }
      
      it "should be a valid card" do
        @card.valid?.should be_true
      end  
      
      describe "authorize" do
        before do
          @address = { :zip =>  @credit_cards[1][:avs] }
          @response = gateway.authorize(@credit_cards[1][:amount], @card, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true, # set Physical goods flag 
                                        :billing_address => @address)
          @transaction_id = @response.authorization
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'M'
          @response.cvv_result['message'].should be == 'Match'
          @response.authorization.should_not be_blank
        end
        
        describe "capture (test 23)" do
          before do
            @response = gateway.capture(@credit_cards[1][:amount], @card, 
                                        @transaction_id, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'A'
            @response.cvv_result['code'].should be == 'M'
            @response.cvv_result['message'].should be == 'Match'
            @response.authorization.should_not be_blank
          end
        end  
        
        describe "void (test 31/32)" do
          before do
            @response = gateway.void(@credit_cards[1][:amount], @card, 
                                     @transaction_id, 
                                     :order_id => Utilities::generate_order,
                                     :shipping_required => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'A'
            @response.cvv_result['code'].should be == 'M'
            @response.cvv_result['message'].should be == 'Match'
            @response.authorization.should_not be_blank
          end          
        end  
      end  
      
      describe "authorize and capture (test 27)" do
        before do
          @response = gateway.purchase(@credit_cards[1][:amount], @card, 
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true, # set Physical goods flag 
                                       :billing_address => @address)
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'M'
          @response.cvv_result['message'].should be == 'Match'
          @response.authorization.should_not be_blank
        end
      end            
    end    

    describe "should pass test 20" do
      before {
        @card = ActiveMerchant::Billing::CreditCard.new({:number => @credit_cards[2][:number].gsub!(' ', ''),
                                                         :verification_value => @credit_cards[2][:verification_value]}.merge(common_options))
      }
      
      it "should be a valid card" do
        @card.valid?.should be_true
      end  
      
      describe "authorize" do
        before do
          @address = { :zip =>  @credit_cards[2][:avs] }
          @response = gateway.authorize(@credit_cards[2][:amount], @card, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true, # set Physical goods flag 
                                        :billing_address => @address)
          @transaction_id = @response.authorization
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'M'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
        end
        
        describe "capture (test 24)" do
          before do
            @response = gateway.capture(@credit_cards[2][:amount], @card, 
                                        @transaction_id,
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'M'
            @response.cvv_result['code'].should be == 'N'
            @response.cvv_result['message'].should be == 'No Match'
            @response.authorization.should_not be_blank
          end
        end    
      end 
      
      describe "authorize and capture (test 28)" do
        before do
          @response = gateway.purchase(@credit_cards[2][:amount], @card, 
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true, # set Physical goods flag 
                                       :billing_address => @address)
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'M'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
        end
      end   
    end    

    describe "should pass test 21" do
      before {
        @card = ActiveMerchant::Billing::CreditCard.new({:number => @credit_cards[3][:number].gsub!(' ', ''),
                                                         :verification_value => @credit_cards[3][:verification_value]}.merge(common_options))
      }
      
      it "should be a valid card" do
        @card.valid?.should be_true
      end  
      
      describe "authorize" do
        before do
          @address = { :zip =>  @credit_cards[3][:avs] }
          @response = gateway.authorize(@credit_cards[3][:amount], @card, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true, # set Physical goods flag 
                                        :billing_address => @address)
          @transaction_id = @response.authorization
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
        end
        
        describe "capture (test 25)" do
          before do
            @response = gateway.capture(@credit_cards[3][:amount], @card, 
                                        @transaction_id,
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'A'
            @response.cvv_result['code'].should be == 'N'
            @response.cvv_result['message'].should be == 'No Match'
            @response.authorization.should_not be_blank
          end
        end    
      end 
      
      describe "authorize and capture (test 29)" do
        before do
          @response = gateway.purchase(@credit_cards[3][:amount], @card, 
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true, # set Physical goods flag 
                                       :billing_address => @address,
                                       :certification_test => true)
          @transaction_id = @response.authorization
          if !@response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_true
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
        end
        
        describe "credit (test 30)" do
          before do
            @response = gateway.close_batch
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
            
            @response = gateway.credit(@credit_cards[3][:amount], @card, 
                                       @transaction_id,
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true,
                                       :certification_test => true)
            if !@response.success?
              puts @response.message
              puts @response.inspect
            end
          end
          
          it "should return the correct response" do
            @response.success?.should be_true
            @response.avs_result['code'].should be == 'A'
            @response.cvv_result['code'].should be == 'N'
            @response.cvv_result['message'].should be == 'No Match'
            @response.authorization.should_not be_blank
          end
        end
      end            
    end

    describe "bad cards" do
      before do
        @card = ActiveMerchant::Billing::CreditCard.new({:number => @bad_card[:number].gsub!(' ', ''),
                                                         :verification_value => @bad_card[:verification_value]}.merge(common_options))
      end
      
      it "should be a valid card" do
        @card.valid?.should be_true
      end  
      
      describe "test 33" do
        before do
          @address = { :zip =>  @bad_card[:avs] }
          @response = gateway.purchase(@bad_card[:amount], @card, 
                                       :order_id => Utilities::generate_order,
                                       :shipping_required => true, # set Physical goods flag 
                                       :billing_address => @address)
          @transaction_id = @response.authorization
          if @response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_false
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
          @response.params['response_reason_text'].should be == 'Declined  Insufficient Funds'
        end
      end
      
      describe "test 34" do
        before do
          @address = { :zip =>  @bad_card[:avs] }
          @response = gateway.authorize(@bad_card[:amount], @card, 
                                        :order_id => Utilities::generate_order,
                                        :shipping_required => true, # set Physical goods flag 
                                        :billing_address => @address)
          @transaction_id = @response.authorization
          if @response.success?
            puts @response.message
            puts @response.inspect
          end
        end
        
        it "should return the correct response" do
          @response.success?.should be_false
          @response.avs_result['code'].should be == 'A'
          @response.cvv_result['code'].should be == 'N'
          @response.cvv_result['message'].should be == 'No Match'
          @response.authorization.should_not be_blank
          @response.params['response_reason_text'].should be == 'Declined  Insufficient Funds'
        end
      end
    end
  end
end
