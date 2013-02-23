describe "VendorMailer" do  
  TEST_EMAIL = 'endymionjkb@gmail.com'
  
  let(:vendor) { FactoryGirl.create(:vendor) }
  before { vendor.user.email = TEST_EMAIL }
  
  subject { vendor }
  
  it { should be_valid }
  it "should have the test email" do
    vendor.user.email.should == TEST_EMAIL
  end

  describe "Signup email" do
    let(:vendor) { FactoryGirl.create(:vendor) }
    let(:msg) { VendorMailer.signup_email(vendor) }
    
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
      
      it "should be copied to the merchant admin" do
        msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_MERCHANT_ADMIN)
      end
      
      it "should have the right subject" do
        msg.subject.should == VendorMailer::SIGNUP_MESSAGE
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("By signing up, you've agreed to the terms of our merchant agreement")
        msg.body.encoded.should match("If you want to print a copy of the merchant agreement, you can download it here")
        # It's chopped because the () interfere with the matching
        msg.body.encoded.should match(ApplicationHelper::MACHOVY_SALES_ADMIN)
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      it "should not have the attachment" do
        msg.attachments.count.should be == 0
        #msg.attachments[0].filename.should == 'VendorAgreement.pdf'
      end
    end
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
          msg.body.encoded.should match(promotion.retail_value.round(2).to_s)
          msg.body.encoded.should match(promotion.price.round(2).to_s)
          msg.body.encoded.should match(promotion.revenue_shared.round().to_s)
          msg.body.encoded.should match(promotion.strategy.description)
          ActionMailer::Base.deliveries.count.should == 1
        end
      end
    end

    describe "approved for vendor with no user" do
      before do
        promotion.status = Promotion::MACHOVY_APPROVED
        promotion.vendor.user = nil
      end
    
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
          msg.to.to_s.should match(ApplicationHelper::MACHOVY_SALES_ADMIN)
        end
        
        it "should have the right subject" do
          msg.subject.should == VendorMailer::PROMOTION_STATUS_MESSAGE
        end
        
        it "should have the right content" do
          msg.body.encoded.should match('Your promotion has been approved')
          msg.body.encoded.should match(promotion.retail_value.round(2).to_s)
          msg.body.encoded.should match(promotion.price.round(2).to_s)
          msg.body.encoded.should match(promotion.revenue_shared.round().to_s)
          msg.body.encoded.should match(promotion.strategy.description)
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

  describe "Payment email" do
    let(:vendor) { FactoryGirl.create(:vendor_with_vouchers) }
    let(:payment) { FactoryGirl.create(:payment, :vendor => vendor)}
    let(:msg) { VendorMailer.payment_email(vendor, payment) }
    
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
        msg.subject.should == VendorMailer::PAYMENT_MESSAGE
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("Please be advised that we have sent you a check")
        msg.body.encoded.should match(payment.check_number.to_s)
        msg.body.encoded.should match(payment.check_date.try(:strftime, ApplicationHelper::DATE_FORMAT))
        msg.body.encoded.should match(payment.amount.round(2).to_s)
        msg.body.encoded.should match("This is in payment for the following vouchers")
        payment.vouchers.each do |voucher|
          msg.body.encoded.should match(voucher.uuid)
          msg.body.encoded.should match(voucher.order.first_name)
          msg.body.encoded.should match(voucher.order.last_name)
        end
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      it "should not have attachments" do
        msg.attachments.count.should be == 0
      end
    end
  end   
end
