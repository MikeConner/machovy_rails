describe "Credit card Case 5 - customer using new card and not saving" do
  VISA = '4242424242424242'
  AMEX = '378282246310005'

  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:approved_promotion) }
  let(:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end

  subject { page }
  
  describe "Sign in" do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      # Authenticate
      click_button I18n.t('sign_in')      
    end

    it "user should not have a customer id" do
      user.customer_id.should be_nil
    end
    
    pending "Customer -- using new card and not saving (case 5)", :js => true do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        check 'cb_save_card'
        click_button I18n.t('buy_now')
      end

#TODO Replace with Vault
=begin      
      after do
        cu = Stripe::Customer.retrieve(user.reload.stripe_id)
        cu.delete
      end
=end                        
      it "should work" do
        page.should_not have_content("RSpec timing issue???")
        order.reload.transaction_id.should_not be_nil
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your voucher')
        msg.attachments.count.should be == 1
        msg.attachments[0].filename.should == Voucher.first.uuid + ".png"
      end
      
      describe "Card should be saved" do
        let(:msg) { ActionMailer::Base.deliveries[0] }
        before do
          visit order_promotion_path(promotion)
          choose 'decision_new'
          fill_in 'card_number', :with => AMEX
          fill_in 'card_code', :with => '444'
          fill_in 'first_name', :with => 'Jeffrey'
          fill_in 'last_name', :with => 'Bennett'
          click_button I18n.t('buy_now')
        end
                      
        it "should work" do
          order.reload.transaction_id.should_not be_nil
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should be == 1
          msg.to.to_s.should match(user.email)
          msg.subject.should be == UserMailer::ORDER_MESSAGE
          msg.body.encoded.should match('Thank you for your order')
          msg.body.encoded.should match('See attachments for your voucher')
          msg.attachments.count.should be == 1
          msg.attachments[0].filename.should be == Voucher.last.uuid + ".png"
          Voucher.count.should == 1
        end    
        
        describe "should still show old card" do
          before { visit order_promotion_path(promotion) }
          
          it { should have_content("Use card with last 4 digits '#{VISA[-4..-1]}'") }
        end              
      end
    end
  end
end
