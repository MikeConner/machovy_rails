describe "Ordering with macho bucks" do
  VISA = '4242424242424242'
  let(:bucks100) { FactoryGirl.create(:macho_buck, :amount => 100) }
  let(:bucks10) { FactoryGirl.create(:macho_buck, :amount => 10) }
  let(:bucksNeg10) { FactoryGirl.create(:macho_buck, :amount => -10) }
  let(:promotion10) { FactoryGirl.create(:promotion, :price => 10) }
  let(:promotion100) { FactoryGirl.create(:promotion, :price => 100) }
  let(:order_msg) { ActionMailer::Base.deliveries[0] }
  let(:bucks_msg) { ActionMailer::Base.deliveries[1] }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end
  
  subject { page }
  
  it "should have the right macho buck totals" do
    bucks100.user.total_macho_bucks.should be == 100
    bucks10.user.total_macho_bucks.should be == 10
    bucksNeg10.user.total_macho_bucks.should be == -10
  end

  describe "Balance: 100, cost 10  (should charge 0 -- no credit card, ending balance 90)" do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => bucks100.user.email
      fill_in 'user_password', :with => bucks100.user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit order_promotion_path(promotion10)    
    end
    
    # Should be invisible, but there
    it { should have_content(I18n.t('credit_card_details')) }
    it { should have_xpath('//div[@id="credit_card_section"]', :visible => false) }
    it { should have_xpath('//input[@id="amount_display" and @value="0"]') }
    
    describe "buy it" do
      before do
        click_button 'Get it NOW'
        @order = promotion10.orders.first
        @bucks = bucks100.user.reload.macho_bucks
      end
            
      it "should work" do
        page.should have_content(I18n.t('order_successful'))
        @order.charge_id.should be == "Macho Bucks"
        bucks100.user.reload.total_macho_bucks.should be == 90
        @bucks.count.should be == 2
        @bucks[0].amount.should be == 100
        @bucks[1].amount.should be == -10
        
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 2
        order_msg.to.to_s.should match(bucks100.user.email)
        order_msg.subject.should be == UserMailer::ORDER_MESSAGE
        order_msg.body.encoded.should match('Thank you for your order')
        order_msg.body.encoded.should match('See attachments for your voucher')
        order_msg.attachments.count.should be == 1
        order_msg.attachments[0].filename.should be == Voucher.first.uuid + ".png"
        
        bucks_msg.to.to_s.should match(bucks100.user.email)        
        bucks_msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_MERCHANT_ADMIN)        
        bucks_msg.subject.should be == UserMailer::MACHO_REDEEM_MESSAGE
        bucks_msg.body.encoded.should match('We applied a credit of 10')
        bucks_msg.body.encoded.should match("90.00.")
        bucks_msg.attachments.count.should be == 0
      end
    end
  end
  
  describe "Balance: 100, cost 100 (should charge 0, ending balance 0)" do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => bucks100.user.email
      fill_in 'user_password', :with => bucks100.user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit order_promotion_path(promotion100)    
    end
    
    # Should be invisible, but there
    it { should have_content(I18n.t('credit_card_details')) }
    it { should have_xpath('//div[@id="credit_card_section"]', :visible => false) }
    it { should have_xpath('//input[@id="amount_display" and @value="0"]') }
    
    describe "buy it" do
      before do
        click_button 'Get it NOW'
        @order = promotion100.orders.first
        @bucks = bucks100.user.reload.macho_bucks
      end
      
      it "should work" do
        page.should have_content(I18n.t('order_successful'))
        @order.charge_id.should be == "Macho Bucks"
        bucks100.user.reload.total_macho_bucks.should be == 0
        @bucks.count.should be == 2
        @bucks[0].amount.should be == 100
        @bucks[1].amount.should be == -100
        
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 2
        order_msg.to.to_s.should match(bucks100.user.email)
        order_msg.subject.should be == UserMailer::ORDER_MESSAGE
        order_msg.body.encoded.should match('Thank you for your order')
        order_msg.body.encoded.should match('See attachments for your voucher')
        order_msg.attachments.count.should be == 1
        order_msg.attachments[0].filename.should be == Voucher.first.uuid + ".png"
        
        bucks_msg.to.to_s.should match(bucks100.user.email)        
        bucks_msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_MERCHANT_ADMIN)        
        bucks_msg.subject.should be == UserMailer::MACHO_REDEEM_MESSAGE
        bucks_msg.body.encoded.should match('We applied a credit of 100')
        bucks_msg.body.encoded.should match("0.00.")
        bucks_msg.attachments.count.should be == 0
      end
    end
  end

  describe "Balance: 10, cost 100  (should charge 90, ending balance 0)" do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => bucks10.user.email
      fill_in 'user_password', :with => bucks10.user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit order_promotion_path(promotion100)    
    end
    
    # Should be invisible, but there
    it { should have_content(I18n.t('credit_card_details')) }
    it { should have_xpath('//div[@id="credit_card_section"]', :visible => true) }
    it { should have_xpath('//input[@id="amount_display" and @value="90.0"]') }
    
    describe "buy it", :js => true do
      before do
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        click_button 'Get it NOW'
        @bucks = bucks10.user.reload.macho_bucks
      end

      it "should work" do
        page.should have_content(I18n.t('order_successful'))
        # Amount is full amount, even if card is charged less!
        Order.first.amount.should be == 100
        Order.first.charge_id.should_not be_nil
        Order.first.charge_id.should_not be == "Macho Bucks"
        bucks10.user.reload.total_macho_bucks.should be == 0
        @bucks.count.should be == 2
        @bucks[0].amount.should be == 10
        @bucks[1].amount.should be == -10
        
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 2
        order_msg.to.to_s.should match(bucks10.user.email)
        order_msg.subject.should be == UserMailer::ORDER_MESSAGE
        order_msg.body.encoded.should match('Thank you for your order')
        order_msg.body.encoded.should match('See attachments for your voucher')
        order_msg.attachments.count.should be == 1
        order_msg.attachments[0].filename.should be == Voucher.first.uuid + ".png"
        
        bucks_msg.to.to_s.should match(bucks10.user.email)        
        bucks_msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_MERCHANT_ADMIN)        
        bucks_msg.subject.should be == UserMailer::MACHO_REDEEM_MESSAGE
        bucks_msg.body.encoded.should match('We applied a credit of 10')
        bucks_msg.attachments.count.should be == 0
        # Seems to have trouble with $
        bucks_msg.body.encoded.should match("0.00.")     
        
        Stripe::Charge.retrieve(Order.first.charge_id).amount.should be == 9000   
      end
    end
  end

  describe "Balance: -10, cost 10  (should charge 20, ending balance 0)" do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => bucksNeg10.user.email
      fill_in 'user_password', :with => bucksNeg10.user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit order_promotion_path(promotion10)    
    end
    
    # Should be invisible, but there
    it { should have_content(I18n.t('credit_card_details')) }
    it { should have_xpath('//div[@id="credit_card_section"]', :visible => true) }
    it { should have_xpath('//input[@id="amount_display" and @value="20.0"]') }
    
    describe "buy it", :js => true do
      before do
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        click_button 'Get it NOW'
        @bucks = bucksNeg10.user.reload.macho_bucks
      end
      
      it "should work" do
        page.should have_content(I18n.t('order_successful'))
        # Amount is full amount, even if card is charged less!
        Order.first.amount.should be == 10
        Order.first.charge_id.should_not be == "Macho Bucks"
        Order.first.charge_id.should_not be_nil
        bucksNeg10.user.reload.total_macho_bucks.should be == 0
        @bucks.count.should be == 2
        @bucks[0].amount.should be == -10
        @bucks[1].amount.should be == 10
        
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 2
        order_msg.to.to_s.should match(bucksNeg10.user.email)
        order_msg.subject.should be == UserMailer::ORDER_MESSAGE
        order_msg.body.encoded.should match('Thank you for your order')
        order_msg.body.encoded.should match('See attachments for your voucher')
        order_msg.attachments.count.should be == 1
        order_msg.attachments[0].filename.should be == Voucher.first.uuid + ".png"
        
        bucks_msg.to.to_s.should match(bucksNeg10.user.email)        
        bucks_msg.bcc.to_s.should match(ApplicationHelper::MACHOVY_MERCHANT_ADMIN)        
        bucks_msg.subject.should be == UserMailer::MACHO_REDEEM_MESSAGE
        bucks_msg.body.encoded.should match('We applied a Macho Bucks deficit of 10')
        bucks_msg.attachments.count.should be == 0
        # Trouble with $; check for total at the end
        bucks_msg.body.encoded.should match("0.00.")
        
        Stripe::Charge.retrieve(Order.first.charge_id).amount.should be == 2000
      end
    end
  end
end