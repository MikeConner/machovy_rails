describe "Order quantity > 1" do
  VISA = '4242424242424242'

  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:promotion) }
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
      user.stripe_id.should be_nil
    end
    
    describe "Not a customer -- order quantity 3, not saving card (case 2)", :js => true do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'order_quantity', :with => '3'
        click_button 'Get it NOW'
      end
            
      it "should work and show the right quantity" do
        # WARNING! have_content doesn't work with single-quoted strings
        page.should have_content(I18n.t('order_successful'))
        user.reload.stripe_id.should be_nil
        Order.first.quantity.should be == 3
        Voucher.count.should be == 3
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your vouchers')
        msg.attachments.count.should be == 3
      end      
    end
  end
end
