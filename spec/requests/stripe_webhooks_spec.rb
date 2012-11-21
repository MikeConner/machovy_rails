describe "Stripe webhooks" do  

  describe "monitored" do
    before do
      log = FactoryGirl.build(:monitored_stripe_log)
      post test_stripe_path, log.event
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
end
