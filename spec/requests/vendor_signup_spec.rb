describe "Vendor signup" do
  before { Role.create!(:name => Role::MERCHANT) }
  
  subject { page }
  
  describe "Sign up" do
    before { visit new_user_registration_path(:merchant => true) }
    
    # Should have the vendor header
    it { should have_selector('h3', :text => 'Not the usual deals site') }
    
    describe "with invalid information" do
      before { click_button "Sign up" }
      
      it { should have_selector('div', :id => 'error_explanation') }
      it { should have_content('Email is invalid') }
    end
    
    describe "with valid information" do
      let (:msg) { ActionMailer::Base.deliveries[0] }
      
      before do
        # Clear any previous emails
        ActionMailer::Base.deliveries = []
        
        fill_in 'user_vendor_attributes_name', :with => 'Cheerleaders'
        fill_in 'user_vendor_attributes_url', :with => 'cheerleaders.com'
        fill_in 'user_vendor_attributes_facebook', :with => 'facebook.com/cheerleaders'
        fill_in 'user_vendor_attributes_address_1', :with => '142 Strip Lane'
        fill_in 'user_vendor_attributes_phone', :with => '724 342-3234'
        fill_in 'user_vendor_attributes_city', :with => 'Pittsburgh'
        fill_in 'user_vendor_attributes_state', :with => 'pa'
        fill_in 'user_vendor_attributes_zip', :with => '15222'
        fill_in 'user_email', :with => 'bob@cheerleaders.com'
        fill_in 'user_password', :with => "Big'Uns"
        fill_in 'user_password_confirmation', :with => "Big'Uns"
        
        click_button "Sign up"
      end
      
      #it "should complete the registration" do
      #  expect { click_button "Sign up" }.to change {Vendor.count}.by(1)
      #end
      
      it "should create vendors and users" do
        Vendor.count.should == 1
        User.count.should == 1
        
        Vendor.find_by_name('Cheerleaders').should_not be_nil
        User.find_by_email('bob@cheerleaders.com').should_not be_nil
        User.find_by_email('bob@cheerleaders.com').has_role?(Role::MERCHANT).should be_true
      end
      
      it "should have sent the email" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        msg.to.to_s.should match('bob@cheerleaders.com')
      end
      
      it "should have the right subject" do
        msg.subject.should == VendorMailer::SIGNUP_MESSAGE
      end
      
      it "should have the right content" do
        msg.body.encoded.should match('Please see the attachment for our standard Vendor agreement')
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      it "should have the attachment" do
        msg.attachments.count.should == 1
        msg.attachments[0].filename.should == 'VendorAgreement.pdf'
      end
    end
  end
end
