describe "Buy Gift Certificate for inappropriate users" do
  VISA = '4242424242424242'

  before do
    Metro.create!(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::CONTENT_ADMIN)
    Role.create(:name => Role::MERCHANT)
    ActionMailer::Base.deliveries = []
    visit root_path
    Warden.test_mode!
  end

  subject { page }
  
  describe "Buy for self" do
    before do
      sign_in_as_a_valid_user
      login_as(@user, :scope => :user)
      visit new_gift_certificate_path 
    end
    
    it { should have_selector('h1', :text => 'Buy a Macho Bucks Gift Certificate') }
    it { should have_button(I18n.t('buy_gift_certificate')) }    
    
    describe "Buy a gift certificate for yourself", :js => true do
      before do
        fill_in :gift_certificate_email, :with => @user.email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
      end
      
      it { should have_content(I18n.t('self_gift')) }
    end            
    
    describe "Buy a gift certificate for an admin", :js => true do
      let(:admin) { FactoryGirl.create(:super_admin_user) }
      before do
        fill_in :gift_certificate_email, :with => admin.email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
      end
      
      it "should have an admin target email" do
        admin.has_role?(Role::SUPER_ADMIN).should be_true
      end
      
      it { should have_content(I18n.t('gift_admin')) }
    end            

    describe "Buy a gift certificate for a content admin", :js => true do
      let(:admin) { FactoryGirl.create(:content_admin_user) }
      before do
        fill_in :gift_certificate_email, :with => admin.email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
      end
      
      it "should have an admin target email" do
        admin.has_role?(Role::CONTENT_ADMIN).should be_true
      end
      
      it { should have_content(I18n.t('gift_admin')) }
    end            
    
    describe "Buy a gift certificate for a vendor", :js => true do
      let(:vendor) { FactoryGirl.create(:merchant_user) }
      before do
        fill_in :gift_certificate_email, :with => vendor.email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
      end
      
      it "should have an admin target email" do
        vendor.has_role?(Role::MERCHANT).should be_true
      end
      
      it { should have_content(I18n.t('gift_admin')) }
    end         
  end
end