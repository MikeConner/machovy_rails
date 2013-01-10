describe "Credit Card Errors" do
  VISA = '4242424242424242'
  DECLINED = '5567 0640 0000 0000'
  INVALID = '3242'
  UNKNOWN = '4242424242424241'
  
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

  describe "Sign in", :js => true do
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      # Authenticate
      click_button I18n.t('sign_in')    
    end

    describe "No names" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("first_name cannot be empty; last_name cannot be empty") }
      
      it "should stay on the page" do
        current_path.should == order_promotion_path(promotion)
      end   
      
      it "should not have created any vouchers" do
        Voucher.count.should == 0
      end
    end

    describe "Invalid CVC" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '44'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("Invalid visa card CVV") }
      
      it "should stay on the page" do
        current_path.should == order_promotion_path(promotion)
      end   
      
      it "should not have created any vouchers" do
        Voucher.count.should == 0
      end
    end

    describe "Invalid Card" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => INVALID
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("brand is required; number is not a valid credit card number") }
      
      it "should stay on the page" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end

    describe "Unknown Card" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => UNKNOWN
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("number is not a valid credit card number") }
      
      it "should stay on the page" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end
  end
end
