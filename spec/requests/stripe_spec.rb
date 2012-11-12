describe "Ordering through Stripe" do
  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
    #post works with the rack-test gem, in case we need it
    #post new_user_session_path, :user => { :email => 'bro@user.com', :password => 'brobro' }
  end
   
  subject { page }
  
  it "user should not have a customer id" do
    user.stripe_id.should be_nil
  end
  
  describe "Sign in first" do
    before do
      # go to sign in page
      click_link 'Sign in / Register'
      # fill in info
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      # Authenticate
      click_button 'Sign in'      
    end
     
    describe "Not a customer -- order without saving (case 2)", :js => true do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => '4242424242424242'
        fill_in 'card_code', :with => '444'
        click_button 'Get it NOW'
        save_page
      end
      
      it { should have_content('Check your email for the details and voucher') }
      
      it "user should not have a customer id" do
        user.stripe_id.should be_nil
      end
      
      it "should have a charge id" do
        order.reload.charge_id.should_not be_nil
      end
      # check for voucher presence and email sending
      
      it "should have a voucher" do
        #order.reload.vouchers.count.should == 1
        Voucher.count.should == 1
      end
   
      it "should have sent the email" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end

      it "should be sent to the right user" do
        msg.to.to_s.should match(user.email)
      end
      
      it "should have the right subject" do
        msg.subject.should == UserMailer::ORDER_MESSAGE
      end
      
      it "should have the right content" do
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your voucher')
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      it "should have attachments" do
        msg.attachments.count.should be == 1
        msg.attachments[0].filename.should == Voucher.first.uuid + ".png"
      end   
    end
  end

=begin
  # User test I can't do without JS
  describe "customer" do
    before {
      @stripe_customer = Stripe::Customer.create(:email => user.email,
                                                 :description => "test description",
                                                 :card => "tok_0acEZLTIMN7ijC")
    }
    
    it "should have a customer object" do
      user.stripe_id.should == @stripe_customer.id
      user.stripe_customer_obj.should == @stripe_customer
    end
    
    describe "deleted" do
      before { @stripe_customer.delete }
      
      it "should delete the customer" do
        user.stripe_id.should == @stripe_customer.id
        @stripe_customer.deleted.should be_true
        user.stripe_customer_obj.should be_nil
      end
    end
  end
=end
end