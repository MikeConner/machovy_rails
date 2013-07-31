describe "Edit suspended promotion" do
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
          @promotion.update_attributes!(:suspended => true)
        end
        
        it "should not be live" do
          @promotion.displayable?.should be_false
          @promotion.suspended?.should be_true
          @promotion.expired?.should be_false
          @promotion.approved?.should be_false
          @promotion.status.should == Promotion::EDITED
        end
        
        it "should have sent email" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should be == 1
          msg.to.to_s.should match(@user.email)
          msg.subject.should be == VendorMailer::PROMOTION_STATUS_MESSAGE
          #msg.body.encoded.should match('We have slightly edited your promotion (or terms)')          
        end
        
        describe "Vendor cannot approve changes (suspended)" do
          before do
            visit root_path
            click_link 'Log out'
            all('a', :text => I18n.t('sign_in_register')).first.click
            # fill in info
            all('#user_email')[0].set(@user.email)
            all('#user_password')[0].set(@user.password)
            # Authenticate
            click_button I18n.t('sign_in')
            visit promotions_path
            click_link 'View'
          end
          
          it "should not be editable" do
            current_path.should be == promotion_path(@promotion.reload)
            page.should_not have_button('Accept Machovy Changes')
            @promotion.reload.expired?.should be_false
            @promotion.reload.approved?.should be_false
            @promotion.reload.suspended?.should be_true
            @promotion.reload.coming_soon?.should be_false
            @promotion.reload.displayable?.should be_false
            @promotion.status.should == Promotion::EDITED
          end
        end
      end
    end
  end
end
