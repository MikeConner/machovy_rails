describe "Product promotion for pickup approved" do
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    ActionMailer::Base.deliveries = []
    visit root_path
  end

  subject { page }

  describe "Sign in and create new promotion" do
    before do
      sign_in_as_a_vendor
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
      select '2016', :from => 'promotion_end_date_1i'
      find(:xpath, "//input[@id='promotion_strategy']").set "Product"
      select 'For pickup', :from => 'delivery'
      click_button 'Submit'
      @promotion = Promotion.first
    end
    
    it "should create promotion" do
      Promotion.count.should be == 1
      @promotion.status.should be == Promotion::PROPOSED
      @promotion.awaiting_machovy_action?.should be_true
      (ProductStrategy === @promotion.strategy).should be_true
      @promotion.strategy.delivery?.should be_false
      current_path.should be == promotion_path(@promotion)
     end
    
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
        click_link @promotion.title
        choose 'decision_accept'
        click_button 'Submit'
      end
      
      it "should be a superadmin user" do
        @admin.has_role?(Role::SUPER_ADMIN).should be_true
      end
      
      describe "should have gone live" do
        let(:msg) { ActionMailer::Base.deliveries[0] }
        before { @promotion = Promotion.first }
        
        it "should be live" do
          @promotion.displayable?.should be_true
        end
        
        it "should have sent email" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should be == 1
          msg.to.to_s.should match(@user.email)
          msg.subject.should be == VendorMailer::PROMOTION_STATUS_MESSAGE
          msg.body.encoded.should match('Your promotion has been approved')          
        end
      end
    end
  end
end
