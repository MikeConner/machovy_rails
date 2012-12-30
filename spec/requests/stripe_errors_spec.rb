describe "Stripe Errors" do
  VISA = '4242424242424242'
  DECLINED = '4000000000000002'
  EXPIRED = '4000000000000069'
  PROCESSING_ERROR = '4000000000000119'
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

    describe "Invalid CVC" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '44'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("Your card's security code is invalid") }
      
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
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("This card number looks invalid") }
      
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
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("Your card number is incorrect") }
      
      it "should stay on the page" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end

    describe "Declined Card" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => DECLINED
        fill_in 'card_code', :with => '444'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("There was a problem with your credit card. Your card was declined") }
      
      it "should stay on the page" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end

    describe "Expired Card" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => EXPIRED
        fill_in 'card_code', :with => '444'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("There was a problem with your credit card. Your card's expiration date is incorrect") }
      
      it "should not produce a voucher" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end

    describe "Processing Error Card" do
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => PROCESSING_ERROR
        fill_in 'card_code', :with => '444'
        click_button I18n.t('buy_now')
      end
         
      it { should have_content("There was a problem with your credit card. An error occurred while processing your card") }
      
      it "should not produce a voucher" do
        current_path.should be == order_promotion_path(promotion)
        Voucher.count.should == 0
      end   
    end
  end
end
