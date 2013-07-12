describe "Promotion created by SalesAdmin" do
  let(:merchant) { FactoryGirl.create(:merchant_user) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    Role.create(:name => Role::SALES_ADMIN)
    ActionMailer::Base.deliveries = []
    visit root_path
  end

  subject { page }

  describe "Sign in and create new promotion", :js => true do
    before do
      merchant
      sign_in_as_a_sales_admin
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit new_promotion_path(:promotion_type => Promotion::LOCAL_DEAL)
      fill_in 'promotion_title', :with => FactoryGirl.generate(:random_phrase)
      fill_in 'promotion_description', :with => FactoryGirl.generate(:random_paragraphs)
      fill_in 'promotion_remote_teaser_image_url', :with => 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
      fill_in 'promotion_remote_main_image_url', :with => 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
      fill_in 'promotion_retail_value', :with => 1000
      fill_in 'promotion_price', :with => 500
      #select '2016', :from => 'promotion_end_date_1i'
      select merchant.vendor.name, :from => 'promotion_vendor_id'
      click_button 'Submit'
      @promotion = Promotion.first
    end
    
    it "should create promotion with EDITED status" do
      Promotion.count.should be == 1
      @promotion.status.should be == Promotion::EDITED
      @promotion.awaiting_vendor_action?.should be_true
      @promotion.awaiting_machovy_action?.should be_false
      @promotion.approved?.should be_false
      @promotion.vendor.should be == merchant.vendor
      merchant.has_role?(Role::MERCHANT).should be_true
      current_path.should be == promotion_path(@promotion)
    end
  end
end
