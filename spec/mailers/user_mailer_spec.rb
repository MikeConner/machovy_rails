describe "UserMailer" do
  TEST_EMAIL = 'endymionjkb@gmail.com'
  FINE_PRINT = 'Here is the fine print'
  INSTRUCTIONS = 'Here is how to redeem the voucher'
  
  let(:order) { FactoryGirl.create(:order_with_vouchers) }
  before { order.email = TEST_EMAIL }
  
  subject { order }
  
  it { should be_valid }
  it "should have the test email" do
    order.email.should == TEST_EMAIL
  end

  describe "Promotion status email" do
    let(:msg) { UserMailer.promotion_order_email(order.reload) }
    before do
      order.promotion.limitations = FINE_PRINT
      order.promotion.voucher_instructions = INSTRUCTIONS
      order.promotion.save!
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
        msg.to.to_s.should match(order.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::ORDER_MESSAGE
      end
      
      it "should have attachments" do
        msg.attachments.count.should == order.vouchers.count
        contents = []
        order.vouchers.each do |voucher|
          str = sprintf("image/png; charset=UTF-8; filename=%s.png", voucher.uuid)
          contents.push(str)
        end
        
        for n in 1..msg.attachments.count do
          contents.include?(msg.attachments[n-1].content_type).should be_true
        end 
      end
      
      it "should have the right content" do
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your voucher')
        msg.body.encoded.should match(FINE_PRINT)
        msg.body.encoded.should match(INSTRUCTIONS)
        order.vouchers.each do |voucher|
          msg.body.encoded.should match(voucher.uuid + ".png")
        end
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end  
end
