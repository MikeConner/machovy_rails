describe "Edit vendor source" do
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    visit root_path
  end

  subject { page }

  describe "Logged in as an admin" do
    let(:promotion) { FactoryGirl.create(:promotion) }
    before do
      promotion
      sign_in_as_an_admin_user
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit merchant_vendors_path
    end
    
    it { should have_selector('h1', :text => 'Manage Vendors') }
    it { should have_link(promotion.vendor.name) }
    
    describe "Edit" do
      before do
        visit edit_merchant_vendor_path(promotion.vendor) 
        fill_in 'vendor_source', :with => 'Jeff'
        click_button 'Update Vendor'
      end
            
      describe "should have an activity" do
        before { @activity = Activity.last }
        
        it "should describe it" do
          promotion.vendor.reload.source.should be == 'Jeff'
          @activity.description.should be == 'Updated source of vendor'
          @activity.activity_name.should be == 'Vendor'
          @activity.activity_id.should be == promotion.vendor.id
        end
      end
    end
  end
end
