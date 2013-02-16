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

  describe "Promotion order email" do
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
        msg.attachments.count.should be == order.vouchers.count
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

  describe "Product order email (delivery)" do
    let(:delivery) { FactoryGirl.create(:product_promotion_with_order) }
    before do
      delivery.limitations = FINE_PRINT
      delivery.voucher_instructions = INSTRUCTIONS
      delivery.save!
      @order = Order.last
      @msg = UserMailer.promotion_order_email(@order)
    end
    
    it "should return a message object" do
      @msg.should_not be_nil
    end
  
    it "should have the right sender" do
      @msg.from.to_s.should match(ApplicationHelper::MAILER_FROM_ADDRESS)
    end
    
    describe "Send the message" do
      before { @msg.deliver }
        
      it "should get queued" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        @msg.to.to_s.should match(@order.email)
        @msg.cc.to_s.should match(@order.promotion.vendor.user.email)
        @msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_SALES_ADMIN)
      end
      
      it "should have the right subject" do
        @msg.subject.should == UserMailer::ORDER_MESSAGE
      end
      
      it "should not have attachments" do
        @msg.attachments.count.should be == 0
      end
      
      it "should have the right content" do
        @msg.body.encoded.should match('Thank you for your order')
        @msg.body.encoded.should match('Shipping instructions')
        @msg.body.encoded.should match(@order.shipping_address)
        @msg.body.encoded.should match(@order.name)
        @msg.body.encoded.should match(FINE_PRINT)
        @msg.body.encoded.should match(INSTRUCTIONS)
        order.vouchers.each do |voucher|
          @msg.body.encoded.should match(voucher.uuid)
        end
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end  

  describe "Product order email (pickup)" do
    let(:delivery) { FactoryGirl.create(:product_pickup_promotion_with_order) }
    before do
      delivery.limitations = FINE_PRINT
      delivery.voucher_instructions = INSTRUCTIONS
      delivery.save!
      @order = Order.last
      @msg = UserMailer.promotion_order_email(@order)
    end
    
    it "should return a message object" do
      @msg.should_not be_nil
    end
  
    it "should have the right sender" do
      @msg.from.to_s.should match(ApplicationHelper::MAILER_FROM_ADDRESS)
    end
    
    describe "Send the message" do
      before { @msg.deliver }
        
      it "should get queued" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        @msg.to.to_s.should match(@order.email)
        @msg.cc.to_s.should match(@order.promotion.vendor.user.email)
        @msg.bcc.to_s.should be_blank
      end
      
      it "should have the right subject" do
        @msg.subject.should == UserMailer::ORDER_MESSAGE
      end
      
      it "should not have attachments" do
        @msg.attachments.count.should be == 0
      end
      
      it "should have the right content" do
        @msg.body.encoded.should match('Thank you for your order')
        @msg.body.encoded.should match('Please pick up your order at')
        #@msg.body.encoded.should match(delivery.vendor.map_address)
        @msg.body.encoded.should match(@order.name)
        @msg.body.encoded.should match(FINE_PRINT)
        @msg.body.encoded.should match(INSTRUCTIONS)
        order.vouchers.each do |voucher|
          @msg.body.encoded.should match(voucher.uuid)
        end
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end  

  describe "Survey email" do
    let(:msg) { UserMailer.survey_email(order.reload) }
    
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
        msg.subject.should == UserMailer::SURVEY_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match('Nice going on redeeming your voucher')
        msg.body.encoded.should match('We always appreciate feedback')
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end  
 
  describe "Unredeem email" do
    let(:msg) { UserMailer.unredeem_email(order.reload.vouchers.first) }
    
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
        msg.subject.should == UserMailer::UNREDEEM_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("has 'unredeemed' your voucher")
        msg.body.encoded.should match("It's now available for immediate use")
        msg.body.encoded.should match(order.reload.vouchers.first.uuid)
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Macho Bucks voucher email" do
    let(:macho_bucks) { FactoryGirl.create(:macho_bucks_from_voucher, :voucher => order.reload.vouchers.first) }
    let(:msg) { UserMailer.macho_bucks_voucher_email(macho_bucks) }
    
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
        msg.to.to_s.should match(macho_bucks.user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::MACHO_CREDIT_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("has 'returned' your voucher")
        msg.body.encoded.should match("Your #{I18n.t('macho_bucks')} will be credited the next time you purchase a local deal")
        msg.body.encoded.should match("Your current #{I18n.t('macho_bucks')} balance")
        msg.body.encoded.should match(order.reload.vouchers.first.uuid)
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Macho Bucks order email" do
    let(:macho_bucks) { FactoryGirl.create(:macho_bucks_from_order, :order => order) }
    let(:msg) { UserMailer.macho_bucks_order_email(macho_bucks) }
    
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
        msg.to.to_s.should match(macho_bucks.user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::MACHO_REDEEM_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("Your current Macho Bucks balance is")
        msg.body.encoded.should match(order.description)
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Gift Certificate redeemed email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:msg) { UserMailer.gift_redeemed_email(certificate) }
    
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
        msg.to.to_s.should match(certificate.user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_REDEEMED_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("Machovy Gift Certificate purchase")
        msg.body.encoded.should match(certificate.email)
        msg.body.encoded.should match(certificate.amount.to_s)
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Gift Certificate given email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:msg) { UserMailer.gift_given_email(certificate) }
    
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
        msg.to.to_s.should match(certificate.user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_GIVEN_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("Machovy Gift Certificate for")
        msg.body.encoded.should match(certificate.email)
        msg.body.encoded.should match(certificate.amount.to_s)
        msg.body.encoded.should match(I18n.t('macho_bucks'))
        msg.body.encoded.should match("We'll let you know when they sign up")
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Gift Certificate received email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:msg) { UserMailer.gift_received_email(certificate) }
    
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
        msg.to.to_s.should match(certificate.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_RECEIVED_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("You have a friend in Machovy")
        msg.body.encoded.should match(certificate.user.email)
        msg.body.encoded.should match(certificate.amount.to_s)
        msg.body.encoded.should match(I18n.t('macho_bucks'))
        msg.body.encoded.should match("create a free account")
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end    

  describe "Gift Certificate given to existing user email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:msg) { UserMailer.gift_given_user_email(certificate) }
    
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
        msg.to.to_s.should match(certificate.user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_GIVEN_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("purchasing a Machovy Gift Certificate")
        msg.body.encoded.should match(certificate.email)
        msg.body.encoded.should match(certificate.amount.to_s)
        msg.body.encoded.should match(I18n.t('macho_bucks'))
        msg.body.encoded.should match("already a Machovy.com member")
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end 

  describe "Gift Certificate credited email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:msg) { UserMailer.gift_credited_email(certificate) }
    
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
        msg.to.to_s.should match(certificate.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_CREDITED_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("You have a friend in Machovy")
        msg.body.encoded.should match(certificate.user.email)
        msg.body.encoded.should match(certificate.amount.to_s)
        msg.body.encoded.should match(I18n.t('macho_bucks'))
        msg.body.encoded.should match("store credits you can use toward any purchase")
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end 

  describe "Gift Certificate recipient update email" do
    let(:certificate) { FactoryGirl.create(:gift_certificate) }
    let(:old_email) { FactoryGirl.generate(:random_email) }
    let(:msg) { UserMailer.gift_update_email(certificate, old_email) }
    
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
        msg.to.to_s.should match(certificate.user.email)
        msg.cc.to_s.should match(certificate.email)
        msg.cc.to_s.should match(old_email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::GIFT_UPDATE_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("has been updated")
        msg.body.encoded.should match(certificate.email)
        msg.body.encoded.should match(old_email)
        msg.body.encoded.should match(certificate.amount.to_s)
        msg.body.encoded.should match(I18n.t('macho_bucks'))
        msg.body.encoded.should match("The recipient has been changed")
      
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end 
end
