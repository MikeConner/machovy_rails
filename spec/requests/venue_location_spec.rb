describe "Create promotion with venue location" do
  TEASER_URL = 'http://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Georgia_Aquarium_-_Giant_Grouper_edit.jpg/220px-Georgia_Aquarium_-_Giant_Grouper_edit.jpg'
  MAIN_URL = 'http://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Pterois_volitans_Manado-e_edit.jpg/220px-Pterois_volitans_Manado-e_edit.jpg'
  SLIDESHOW_URL = 'http://upload.wikimedia.org/wikipedia/commons/4/48/DunkleosteusSannoble.JPG'
  
  before do
    Role.create!(:name => Role::MERCHANT)
    Role.create!(:name => Role::SUPER_ADMIN)
    Metro.create!(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end
  
  subject { page }
  
  describe "Sign in" do
    before do
      sign_in_as_a_vendor
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')    
    end
    
    it "should redirect to promotions on vendor signup" do
      current_path.should == promotions_path
    end

    it "should be a vendor user" do
      @user.vendor.should_not be_nil
      @user.has_role?(Role::MERCHANT).should be_true
    end

    it { should have_content(I18n.t('devise.sessions.signed_in')) }
    it { should have_selector('h1', :text => I18n.t('promotions.index_heading')) }
    it { should_not have_selector('h4', :text => I18n.t('promotions.live')) }
    it { should_not have_selector('h4', :text => I18n.t('promotions.attention')) }
    it { should_not have_selector('h4', :text => I18n.t('promotions.pending')) }
    it { should_not have_selector('h4', :text => I18n.t('promotions.inactive')) }
    # We haven't created any ads, so this shouldn't be displayed
    it { should_not have_selector('h3', :text => I18n.t('promotions.ads')) }
    it { should have_link('Create Promotion', :href => new_promotion_path(:promotion_type => Promotion::LOCAL_DEAL)) }
   
    describe "new promotion" do
      before { click_link 'Create Promotion' }
      
      it { should have_selector('h4', :text => I18n.t('new_promotion')) }
      it { should have_selector('#promotion_revenue_shared') }
      it { should have_selector('#promotion_quantity') }
      it { should have_selector('#promotion_strategy') }
      it { should have_content(Promotion::DEFAULT_REVENUE_SHARE) }
      it { should have_content(Promotion::DEFAULT_STRATEGY) }
      
      describe "create" do
        before do
          fill_in 'promotion_title', :with => FactoryGirl.generate(:random_phrase)
          fill_in 'promotion_description', :with => FactoryGirl.generate(:random_paragraphs)
          fill_in 'promotion_limitations', :with => FactoryGirl.generate(:random_paragraphs)
          fill_in 'promotion_voucher_instructions', :with => FactoryGirl.generate(:random_sentences)
          fill_in 'promotion_remote_teaser_image_url', :with => TEASER_URL
          fill_in 'promotion_remote_main_image_url', :with => MAIN_URL
          fill_in 'promotion_promotion_images_attributes_0_remote_slideshow_image_url', :with => SLIDESHOW_URL
          # Tolerate $ in prices
          fill_in 'promotion_retail_value', :with => '$200'
          fill_in 'promotion_price', :with => '$100'
          # Can't "fill_in" a hidden field
          select '65', :from => 'promotion_revenue_shared'
          fill_in 'promotion_quantity', :with => 100
          fill_in 'promotion_venue_name', :with => 'Alpine Club'
          fill_in 'promotion_venue_address', :with => '135 Drood Ln'
          fill_in 'promotion_venue_city', :with => 'Pittsburgh'
          fill_in 'promotion_venue_state', :with => 'PA'
          fill_in 'promotion_venue_zipcode', :with => '15237'
          
          click_button 'Submit'
        end
        
        describe "promo page" do
          before { @p = Promotion.first }
          
          it "should redirect to show the promotion" do
            current_path.should == promotion_path(@p)
          end
        
          it "should have pending status and correct commission" do
            @p.status.should be == Promotion::PROPOSED
            @p.revenue_shared.should be == 65
          end
          
          it "should compute address correctly" do
            @p.venue_location.should be == 'Alpine Club<br>135 Drood Ln<br>Pittsburgh, PA  15237<br>'
            @p.venue_geocode_location.should be == '135 Drood Ln, Pittsburgh, PA 15237'
          end
          
          it "should have latitude/longitude" do
            @p.latitude.should_not be_nil
            @p.longitude.should_not be_nil
            @p.mappable?.should be_true
          end
          
          it { should have_selector('h3', :text => @p.title) }
          it { should have_xpath("//ul[@class='rslides']") }
          # Matching the whole description doesn't work because of truncation; just match part of it
          it { should have_content(@p.description[0, 24]) }
        
          describe "Switch to admin" do
            before do
              click_link 'Log out'
              @admin = FactoryGirl.create(:user)
              @admin.roles << Role.find_by_name(Role::SUPER_ADMIN)
              all('a', :text => I18n.t('sign_in_register')).first.click
              # fill in info
              all('#user_email')[0].set(@admin.email)
              all('#user_password')[0].set(@admin.password)
              # Authenticate
              click_button I18n.t('sign_in')
              visit promotions_path
              click_link @p.title
              fill_in 'promotion_venue_address', :with => ''
              
              click_button 'Submit'
            end
            
            it "should not be mappable" do
              @p.reload.mappable?.should be_false
            end
          end
        end
      end
    end
  end    
end