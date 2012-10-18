describe "VendorMailer" do
  TEST_EMAIL = 'endymionjkb@gmail.com'
  
  let(:vendor) { FactoryGirl.create(:vendor) }
  before { vendor.user.email = TEST_EMAIL }
  
  subject { vendor }
  
  it { should be_valid }
  it "should have the test email" do
    vendor.user.email.should == TEST_EMAIL
  end
  
  describe "Promotion status email" do
    let(:promotion) { FactoryGirl.create(:promotion, :vendor => vendor) }
    let(:msg) { VendorMailer.promotion_status_email(promotion) }
    
    describe "approved" do
      before { promotion.status = Promotion::MACHOVY_APPROVED }
    
      it "should return a message object" do
        msg.should_not be_nil
      end
    
      it "should have the right sender" do
        msg.from.to_s.should match(ApplicationHelper::MAILER_FROM_ADDRESS)
      end
      
      describe "Send the message" do
        before { msg.deliver }
          
        it "should get queued" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should == 1
        end
        # msg.to is a Mail::AddressContainer object, not a string
        # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
        it "should be sent to the right user" do
          msg.to.to_s.should match(vendor.user.email)
        end
        
        it "should have the right subject" do
          msg.subject.should == VendorMailer::PROMOTION_STATUS_MESSAGE
        end
        
        it "should have the right content" do
          msg.body.encoded.should match('Your promotion has been approved')
          ActionMailer::Base.deliveries.count.should == 1
        end
      end
    end

    describe "rejected" do
      before { promotion.status = Promotion::MACHOVY_REJECTED }
    
      it "should return a message object" do
        msg.should_not be_nil
      end
    
      it "should have the right sender" do
        msg.from.to_s.should match(ApplicationHelper::MAILER_FROM_ADDRESS)
      end
      
      describe "Send the message" do
        before { msg.deliver }
          
        it "should get queued" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should == 1
        end
        # msg.to is a Mail::AddressContainer object, not a string
        # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
        it "should be sent to the right user" do
          msg.to.to_s.should match(vendor.user.email)
        end
        
        it "should have the right subject" do
          msg.subject.should == VendorMailer::PROMOTION_STATUS_MESSAGE
        end
        
        it "should have the right content" do
          msg.body.encoded.should match('Your promotion has been rejected')
          ActionMailer::Base.deliveries.count.should == 1
        end
      end
    end
    
    describe "edited" do
      before { promotion.status = Promotion::EDITED }
    
      it "should return a message object" do
        msg.should_not be_nil
      end
    
      it "should have the right sender" do
        msg.from.to_s.should match(ApplicationHelper::MAILER_FROM_ADDRESS)
      end
      
      describe "Send the message" do
        before { msg.deliver }
          
        it "should get queued" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should == 1
        end
        # msg.to is a Mail::AddressContainer object, not a string
        # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
        it "should be sent to the right user" do
          msg.to.to_s.should match(vendor.user.email)
        end
        
        it "should have the right subject" do
          msg.subject.should == VendorMailer::PROMOTION_STATUS_MESSAGE
        end
        
        it "should have the right content" do
          msg.body.encoded.should match('We have slightly edited your promotion')
          ActionMailer::Base.deliveries.count.should == 1
        end
      end
    end
    
    describe "inappropriate status" do
      before { promotion.status = Promotion::PROPOSED }
    
      it "should not return a message object" do
        expect { msg }.to raise_exception(RuntimeError)
      end
    end    
  end  
end
