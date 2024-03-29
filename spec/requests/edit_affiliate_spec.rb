describe "Edit Affiliate deal" do
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    FactoryGirl.create(:vendor)
    visit root_path
    Warden.test_mode!
  end

  subject { page }

  describe "Sign in and create new affiliate promotion", :js => true do
    before do
      sign_in_as_an_admin_user
      login_as(@user, :scope => :user)
      #@admin = FactoryGirl.create(:user)
      #@admin.roles << Role.find_by_name(Role::SUPER_ADMIN)
=begin
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      save_page # for timing
      all('#user_email')[0].set(@admin.email)
      all('#user_password')[0].set(@admin.password)
      # Authenticate
      click_button I18n.t('sign_in')
=end
      visit new_promotion_path(:promotion_type => Promotion::AFFILIATE)
      select Vendor.first.name, :from => 'promotion_vendor_id'
      fill_in 'raw_affiliate_url', :with => 'http://www.amazon.com/gp/product/B008GGCAVM/ref=gw_c1_tatehhol_img'
      fill_in 'promotion_title', :with => FactoryGirl.generate(:random_phrase)
      fill_in 'promotion_description', :with => FactoryGirl.generate(:random_paragraphs)
      fill_in 'promotion_remote_teaser_image_url', :with => 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
      select '2016', :from => 'promotion_end_date_1i'
      click_button 'Create Affiliate'
      save_page
      @promotion = Promotion.first
      save_page
      # wait_until removed in Capybara 2.0
      # wait_until { page.evaluate_script('$.active') == 0 }
#      page.driver.wait_until { page.driver.browser.find_element(:css, "div.product_detail").displayed? == true }
    end
    
    it "should create promotion" do
      #Promotion.count.should be == 1
      @promotion.status.should be == Promotion::MACHOVY_APPROVED
      @promotion.awaiting_machovy_action?.should be_false
      @promotion.approved?.should be_true
      current_path.should be == promotion_path(@promotion)
    end
  end
      
  describe "Edit the promotion" do
    let(:promotion) { FactoryGirl.create(:affiliate) }
    before do
      sign_in_as_an_admin_user
      
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      save_page # for timing
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      
      visit edit_promotion_path(promotion)
      save_page
      fill_in 'promotion_subtitle', :with => '... or Melinda'
      click_button 'Submit'
    end
    
    it "should have the change" do
      promotion.reload.subtitle.should == '... or Melinda'
    end
  end
end
