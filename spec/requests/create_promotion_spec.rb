describe "Demo spec" do
  TEASER_URL = 'http://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Georgia_Aquarium_-_Giant_Grouper_edit.jpg/220px-Georgia_Aquarium_-_Giant_Grouper_edit.jpg'
  MAIN_URL = 'http://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Pterois_volitans_Manado-e_edit.jpg/220px-Pterois_volitans_Manado-e_edit.jpg'
  SLIDESHOW_URL = 'http://upload.wikimedia.org/wikipedia/commons/4/48/DunkleosteusSannoble.JPG'
  
  let(:user) { FactoryGirl.create(:user) }
  let(:vendor) { FactoryGirl.create(:vendor, :user => user) }
  before do
    Role.create!(:name => Role::MERCHANT)
    Metro.create!(:name => 'Pittsburgh')
    user.roles << Role.find_by_name(Role::MERCHANT)
    ActionMailer::Base.deliveries = []
    visit root_path
  end
  
  subject { page }
  
  describe "Sign in" do
    before do
      # go to sign in page
      click_link 'Sign In'
      # fill in info
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      # Authenticate
      click_button 'Sign in'      
    end
    
    it "should redirect to promotions on vendor signup" do
      current_path.should == promotions_path
    end

    it { should have_content(I18n.t('devise.sessions.signed_in')) }
    it { should have_selector('h1', :text => I18n.t('promotions.index_heading')) }
    it { should have_selector('h3', :text => I18n.t('promotions.live')) }
    it { should have_selector('h3', :text => I18n.t('promotions.attention')) }
    it { should have_selector('h3', :text => I18n.t('promotions.pending')) }
    it { should have_selector('h3', :text => I18n.t('promotions.inactive')) }
    it { should_not have_selector('h3', :text => I18n.t('promotions.ads')) }
    it { should have_link('New Promotion', :href => new_promotion_path(:promotion_type => Promotion::LOCAL_DEAL)) }
    
    describe "new promotion" do
      before { click_link 'New Promotion' }
      
      it { should have_selector('h1', 'New Promotion') }
      it "should have the default revenue share" do
        #page.has_xpath?("//#promotion_revenue_shared") 
        find(:xpath, './/#promotion_revenue_shared').text.should match(Promotion::MINIMUM_REVENUE_SHARE)
      end
      
      describe "create" do
        before do
          fill_in 'promotion_title', :with => FactoryGirl.generate(:random_description)
          fill_in 'promotion_description', :with => FactoryGirl.generate(:random_post)
          fill_in 'promotion_limitations', :with => FactoryGirl.generate(:random_post)
          fill_in 'voucher_instructions', :with => FactoryGirl.generate(:random_comment)
          fill_in 'promotion_remote_teaser_image_url', :with => TEASER_URL
          fill_in 'promotion_remote_main_image_url', :with => MAIN_URL
          fill_in 'promotion_promotion_images_attributes_0_remote_slideshow_image_url', :with => SLIDESHOW_URL
          fill_in 'promotion_promotion_images_attributes_0_caption', :with => FactoryGirl.generate(:random_description)
          fill_in 'promotion_retail_value', :with => 200
          fill_in 'promotion_price', :with => 100
          fill_in 'promotion_revenue_shared', :with => 10
          fill_in 'promotion_quantity', :with => 100
          
          click_button 'Create Promotion'
        end
      end
    end
  end
end