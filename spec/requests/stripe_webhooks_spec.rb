describe "Stripe webhooks" do  

  describe "monitored" do
    before do
      log = FactoryGirl.build(:monitored_stripe_log)
      post test_stripe_path, log.event
    end
    
    it "should not have a user" do
      StripeLog.first.user.should be_nil
    end
    
    it "should create a log" do
      StripeLog.count.should == 1
    end
  end
  
  describe "unmonitored" do
    describe "post it" do
      before do
        log = FactoryGirl.build(:unmonitored_stripe_log)
        post test_stripe_path, log.event
      end
      
      it "should not create a log" do
        StripeLog.count.should == 0
      end
    end
  end
  
  describe "user" do
    let(:user) { FactoryGirl.create(:user, :stripe_id => 'cus_00000000000001') }
    let(:log) { FactoryGirl.build(:stripe_log) }
    
    describe "post by customer" do
      before do
        evt = JSON.parse log.event, :symbolize_names => true
        evt[:data][:object][:customer] = user.stripe_id
        log.event = evt.to_json
        
        post test_stripe_path, log.event
        @event = StripeLog.last
      end
      
      it "should detect the user" do
        @event.user.id.should be == user.id
        user.stripe_logs.first.id.should == @event.id
      end
    end

    describe "post by email" do
      before do
        evt = JSON.parse log.event, :symbolize_names => true
        evt[:data][:object].delete(:email)
        evt[:data][:object][:email] = user.email
        log.event = evt.to_json
        
        post test_stripe_path, log.event
        @event = StripeLog.last
      end
      
      it "should detect the user" do
        @event.user.id.should be == user.id
        user.stripe_logs.first.id.should == @event.id
      end
    end
  end
end
