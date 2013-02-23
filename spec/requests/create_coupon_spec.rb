describe "Coupon created by SalesAdmin" do
  let(:merchant) { FactoryGirl.create(:merchant_user) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    Role.create(:name => Role::SALES_ADMIN)
    visit root_path
  end

  subject { page }

  describe "Sign in and create new coupon" do
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
      visit new_coupon_path
      fill_in 'coupon_title', :with => FactoryGirl.generate(:random_phrase)
      fill_in 'coupon_description', :with => FactoryGirl.generate(:random_paragraphs)
      fill_in 'coupon_remote_coupon_image_url', :with => 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
      fill_in 'coupon_value', :with => 100
      click_button 'Create Coupon'
      @coupon = Coupon.first
    end
    
    it "should create coupon" do
      Coupon.count.should be == 1
      merchant.has_role?(Role::MERCHANT).should be_true
      current_path.should be == coupon_path(@coupon)
      page.should have_content("External link:")
    end
    
    describe "Can't get there without logging in" do
      before do
        visit root_path
        click_link 'Log out'
        visit coupon_path(Coupon.first)        
      end
      
      it { should have_content(I18n.t('devise.failure.unauthenticated')) }
    end
    
    describe "Switch to admin" do
      before do
        visit root_path
        click_link 'Log out'
        @admin = FactoryGirl.create(:user)
        @admin.roles << Role.find_by_name(Role::SUPER_ADMIN)
        all('a', :text => I18n.t('sign_in_register')).first.click
        # fill in info
        all('#user_email')[0].set(@admin.email)
        all('#user_password')[0].set(@admin.password)

        # Authenticate
        click_button I18n.t('sign_in')
        visit coupons_path
        @coupon = Coupon.first
      end
      
      it { should have_link('Delete') }
      it { should have_link(@coupon.title) }
      it { should have_link(@coupon.vendor.name) }
      
      describe "Edit it" do
        before do
          click_link @coupon.title
          fill_in 'coupon_value', :with => 250
          click_button 'Update Coupon'
        end
        
        it "should have updated" do
          @coupon.reload.value.should be == 250
        end
      end
    end    
  end
end
