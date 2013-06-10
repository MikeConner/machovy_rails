describe "Vendor signup" do
  before do
    Role.create!(:name => Role::MERCHANT)
    Metro.create!(:name => 'Pittsburgh')
  end
  VENDOR_EMAIL = 'bob@cheerleaders.com'
  
  subject { page }
  
  describe "Sign up" do
    before { visit new_user_registration_path }
    
    # Should have the vendor header
    it { should have_selector('h1', :text => I18n.t('merchant_signup')) }
    
    describe "with invalid information" do
      before { click_button "Sign up" }
      
      it { should have_content("Password can't be blank") }
      it "should return to the right page" do
        current_path.should == user_registration_path
      end
    end
    
    describe "with valid information" do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      
      before do
        # Clear any previous emails
        ActionMailer::Base.deliveries = []
        
        fill_in 'user_vendor_attributes_name', :with => 'Cheerleaders'
        fill_in 'user_vendor_attributes_url', :with => 'cheerleaders.com'
        fill_in 'user_vendor_attributes_facebook', :with => 'facebook.com/cheerleaders'
        fill_in 'user_vendor_attributes_address_1', :with => '3100 Liberty Ave'
        fill_in 'user_vendor_attributes_phone', :with => '724 342-3234'
        fill_in 'user_vendor_attributes_city', :with => 'Pittsburgh'
        fill_in 'user_vendor_attributes_state', :with => 'pa'
        fill_in 'user_vendor_attributes_zip', :with => '15201'
        fill_in 'user_email', :with => VENDOR_EMAIL
        fill_in 'user_password', :with => "Big'Uns"
        fill_in 'user_password_confirmation', :with => "Big'Uns"
        
        click_button "Sign up"
      end
      
      it "should create vendors and users" do
        Vendor.count.should be == 1
        User.count.should be == 1
        
        Vendor.find_by_name('Cheerleaders').should_not be_nil
        User.find_by_email(VENDOR_EMAIL).should_not be_nil
      end
      
      describe "should have geocoded it" do
        before { @vendor = Vendor.find_by_name('Cheerleaders') }
        
        it "should not be empty" do
          puts @vendor.inspect
          @vendor.latitude.should_not be_nil
          @vendor.longitude.should_not be_nil
          @vendor.latitude.round(2).should be == 40.46
          @vendor.longitude.round(2).should be == -79.97
        end
      end
      
      it "should have sent the email" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        msg.to.to_s.should match(VENDOR_EMAIL)
      end
      
      it "should have the right subject" do
        msg.subject.should == I18n.t('devise.mailer.confirmation_instructions.subject')
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("Welcome #{VENDOR_EMAIL}!")
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      describe "Confirmation" do
        let(:msg) { ActionMailer::Base.deliveries[1] }
        before { visit user_confirmation_path(:confirmation_token => User.find_by_email(VENDOR_EMAIL).confirmation_token) }
        
        # Note that this logs in the merchant, which redirects to the promotions_path page
        it "should have gone to promotions path" do
          current_path.should == promotions_path
        end
        it { should have_content(I18n.t('devise.confirmations.confirmed_vendor')) }
        it { should have_link('My Deals') }
        
        it "should have the role assigned" do
          User.find_by_email(VENDOR_EMAIL).has_role?(Role::MERCHANT).should be_true
        end
        
        it "should have sent the email" do
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.count.should == 2
        end
        
        it "should have the right subject" do
          msg.subject.should == VendorMailer::SIGNUP_MESSAGE
        end
        
        it "should have the right content" do
          msg.body.encoded.should match('Welcome to Machovy!')
          ActionMailer::Base.deliveries.count.should == 2
        end

        it "should not have the attachment" do
          msg.attachments.count.should be == 0
          #msg.attachments[0].filename.should == 'VendorAgreement.pdf'
        end
      end      
    end
  end
end
