describe "Buy Gift Certificate (non-standard and error conditions)" do
  VISA = '4242424242424242'

  before do
    Metro.create!(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
    Warden.test_mode!
  end

  subject { page }
  
  describe "Sign in" do
    let(:target_email) { FactoryGirl.generate(:random_email) }
    before do
      sign_in_as_a_valid_user
      login_as(@user, :scope => :user)
      visit new_gift_certificate_path 
      save_page
    end
    
    it { should have_selector('h1', :text => 'Buy a Macho Bucks Gift Certificate') }
    it { should have_button(I18n.t('buy_gift_certificate')) }    

    describe "Buy a gift certificate for a non-default amount", :js => true do
      before do
        fill_in 'gift_certificate_email', :with => target_email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        choose "predetermined_250"
        click_button I18n.t('buy_gift_certificate')
        save_page
        sleep 1 # shameful
        @certificate = GiftCertificate.first
      end
      
      it "should succeed" do
        #GiftCertificate.count.should be == 1
        @certificate.amount.should be == 250
      end
    end            
    
    describe "Buy a gift certificate with no email", :js => true do
      before do
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
      end
      
      it { should have_content("Email can't be blank") }
    end            

    describe "Buy a gift certificate with no amount", :js => true do
      before do
        fill_in 'gift_certificate_email', :with => target_email
        find(:xpath, "//input[@id='gift_certificate_amount']").set " "

        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        save_page
        click_button I18n.t('buy_gift_certificate')
      end
      
      it { should have_content("Amount can't be blank") }
    end            
  end
end