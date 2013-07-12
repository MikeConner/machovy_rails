describe "Edit coming soon promotion" do
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    ActionMailer::Base.deliveries = []
    visit root_path
  end

  subject { page }

  describe "Sign in and create new promotion", :js => true do
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
      #select '2016', :from => 'promotion_end_date_1i'
      click_button 'Submit'
      @promotion = Promotion.first
    end
    
    it "should create promotion" do
      Promotion.count.should be == 1
      @promotion.status.should be == Promotion::PROPOSED
      @promotion.awaiting_machovy_action?.should be_true
      @promotion.approved?.should be_false
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
        choose 'decision_edit'
        fill_in 'comment', :with => 'Almost but not quite'
        
        click_button 'Submit'
      end
      
      it "should be a superadmin user" do
        @admin.has_role?(Role::SUPER_ADMIN).should be_true
      end
      
      describe "should not have gone live" do
        let(:msg) { ActionMailer::Base.deliveries[0] }
        before do 
          @promotion = Promotion.first
          @promotion.update_attributes!(:pending => true, :status => Promotion::MACHOVY_APPROVED)
        end
        
        it "should not be live" do
          @promotion.displayable?.should be_false
          @promotion.suspended?.should be_false
          @promotion.coming_soon?.should be_true
          @promotion.expired?.should be_false
          @promotion.approved?.should be_true
          @promotion.status.should == Promotion::MACHOVY_APPROVED
        end
      end
    end
  end
end
