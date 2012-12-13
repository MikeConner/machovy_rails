describe "Login menus" do
  before do
    Role.create!(:name => Role::MERCHANT)
    Role.create!(:name => Role::SUPER_ADMIN)
    Metro.create!(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end
  
  subject { page }
  
  describe "Admin" do
    before do
      sign_in_as_an_admin_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')    
    end
    
    it { should have_link('Log out') }
    
    it "should have the right links" do
      page.should have_selector('li', :class => 'nav-label', :text => 'Admin')
      page.should have_selector('li', :class => 'nav-label', :text => 'Profile')
      page.should_not have_selector('li', :class => 'nav-label', :text => 'Merchant')
      page.should_not have_selector('li', :class => 'nav-label', :text => 'User')
      page.should have_link('Site Admin')
      page.should have_link('Rails Admin')
      page.should have_link('My Vouchers')
      page.should have_link('Edit profile')
      page.should have_link('Change password')
    end
  end  
  
  describe "Merchant" do
    before do
      #sign_in_as_a_valid_user
      sign_in_as_a_vendor
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')    
    end
    
    it { should have_link('Log out') }
    
    it "should have the right links" do
      page.should_not have_selector('li', :class => 'nav-label', :text => 'Admin')
      page.should_not have_selector('li', :class => 'nav-label', :text => 'User')
      page.should have_selector('li', :class => 'nav-label', :text => 'Merchant')
      page.should have_link('My Deals', :href => promotions_path)
      page.should have_link('My Vouchers', :href => merchant_vouchers_path)
      page.should have_link('Payments')
      page.should have_link('Change password')
    end
  end  

  describe "User" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      # Authenticate
      click_button I18n.t('sign_in')    
    end
    
    it { should have_link('Log out') }
    
    it "should have the right links" do
      page.should have_selector('li', :class => 'nav-label', :text => 'User')
      page.should have_selector('li', :class => 'nav-label', :text => 'Profile')
      page.should have_link('My Vouchers')
      page.should have_link('Edit profile')
      page.should have_link('Change password')
    end
  end  
end
