describe "Create promotion without images" do
  before do
    Role.create!(:name => Role::MERCHANT)
    Metro.create!(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end
  
  subject { page }
  
  describe "Sign in" do
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
      it { should have_selector('input', :id => 'promotion_revenue_shared', :value => Promotion::DEFAULT_REVENUE_SHARE) }
      it { should have_selector('input', :id => 'promotion_quantity', :value => Promotion::DEFAULT_QUANTITY) }
      it { should have_selector('input', :id => 'promotion_strategy', :value => Promotion::DEFAULT_STRATEGY) }
      
      describe "create" do
        before do
          fill_in 'promotion_title', :with => FactoryGirl.generate(:random_phrase)
          fill_in 'promotion_description', :with => FactoryGirl.generate(:random_paragraphs)
          fill_in 'promotion_limitations', :with => FactoryGirl.generate(:random_paragraphs)
          fill_in 'promotion_voucher_instructions', :with => FactoryGirl.generate(:random_sentences)
           # Tolerate $ in prices
          fill_in 'promotion_retail_value', :with => '$200'
          fill_in 'promotion_price', :with => '$100'
          # Can't "fill_in" a hidden field
          select '10', :from => 'promotion_revenue_shared'
          fill_in 'promotion_quantity', :with => 100
          
          click_button 'Submit'
        end
        
        describe "promo page" do
          before { @p = Promotion.first }
          
          it "should redirect to show the promotion" do
            current_path.should == promotion_path(@p)
          end
        
          it "should have pending status" do
            @p.status.should == Promotion::PROPOSED
          end
          
          it { should have_selector('h3', :text => @p.title) }
          it { should have_xpath("//ul[@class='rslides']") }
          # Matching the whole description doesn't work because of truncation; just match part of it
          it { should have_content(@p.description[0, 24]) }
        end  
      end
    end    
  end
end