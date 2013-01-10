describe "Buy product" do
  VISA = '4242424242424242'

  let(:user) { FactoryGirl.create(:user) }
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
    
    describe "Order a product for delivery", :js => true do
      let(:promotion) { FactoryGirl.create(:product_promotion_with_order) }
      let(:order) { Order.last }  
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        fill_in 'order_name', :with => FactoryGirl.generate(:random_name)
        fill_in 'order_address_1', :with => FactoryGirl.generate(:random_street)
        fill_in 'order_city', :with => FactoryGirl.generate(:random_city)
        fill_in 'order_state', :with => FactoryGirl.generate(:random_state)
        fill_in 'order_zipcode', :with => FactoryGirl.generate(:random_zip)
        click_button I18n.t('buy_now')
        save_page
      end
            
      it "should work" do
        # WARNING! have_content doesn't work with single-quoted strings
        page.should have_content(I18n.t('order_successful'))
        user.reload.customer_id.should be_nil
        order.reload.transaction_id.should_not be_nil
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('Your order will be shipped to')
        msg.body.encoded.should match(order.shipping_address)
        msg.attachments.count.should be == 0
      end      
    end

    describe "Order a product for pickup", :js => true do
      let(:promotion) { FactoryGirl.create(:product_pickup_promotion_with_order) }
      let(:order) { Order.last }  
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_now')
        save_page
      end
            
      it "should work" do
        # WARNING! have_content doesn't work with single-quoted strings
        page.should have_content(I18n.t('order_successful'))
        user.reload.customer_id.should be_nil
        order.reload.transaction_id.should_not be_nil
        Voucher.count.should be == 1
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('Please pick up your order at')
        msg.body.encoded.should match(promotion.vendor.map_address)
        msg.attachments.count.should be == 0
      end      
    end
  end
end
