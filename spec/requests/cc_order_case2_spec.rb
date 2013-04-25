describe "Case 2 - Not customer, not saving card" do
  VISA = '4444333322221111'

  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:approved_promotion) }
  let(:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
    Warden.test_mode!
  end

  subject { page }

  describe "Sign in" do
    before do
      sign_in_as_a_valid_user
      login_as(@user, :scope => :user)
=begin
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      save_page # for timing
      all('#user_email')[0].set(user.email)
      all('#user_password')[0].set(user.password)
      # Authenticate
      click_button I18n.t('sign_in')    
=end
    end

    it "user should not have a customer id" do
      user.customer_id.should be_nil
    end
    
    describe "Not a customer -- order not saving card (case 2)", :js => true do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_now')
      end
            
      it "should work" do
        # WARNING! have_content doesn't work with single-quoted strings
        page.should have_content(I18n.t('order_successful'))
        user.reload.customer_id.should be_nil
        order.reload.transaction_id.should_not be_nil
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(@user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your voucher')
        msg.attachments.count.should be == 1
        msg.attachments[0].filename.should == Voucher.first.uuid + ".png"
      end
      
      pending "Card should not be saved" do
        before do 
          @stripe_obj = user.reload.stripe_customer_obj
          visit order_promotion_path(promotion)
        end
        
        it "should not have a customer record" do
          @stripe_obj.should be_nil
        end
        
        it { should_not have_content "Use card with last 4 digits" }
      end
    end
  end
end
