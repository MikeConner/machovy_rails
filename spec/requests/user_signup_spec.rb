describe "User signup" do
  before { Metro.create!(:name => 'Pittsburgh') }
    
  subject { page }
  
  describe "Sign up" do
    before { visit new_user_session_path }
    
    # Should have the user header
    it { should have_selector('h4', :text => I18n.t('create_account_action')) }
    it { should_not have_selector('h4', :text =>  I18n.t('merchant_signup')) }
    
    describe "with invalid information" do
      before { click_button I18n.t('create_account') }
      
      it { should have_content(I18n.t('devise.failure.invalid')) }
      it "should not redirect to the merchant page" do
        current_path.should == new_user_session_path
      end
    end
    
    describe "with valid information" do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      
      before do
        visit new_user_session_path
        # Clear any previous emails
        ActionMailer::Base.deliveries = []

        within(".sign-up-block") do
          fill_in 'user_email', :with => 'jeff@machovy.com'
          fill_in 'user_password', :with => "machoman"
        end
        fill_in 'user_password_confirmation', :with => "machoman"
        
        click_button I18n.t('create_account')
      end
            
      it "should create a user" do
        User.count.should be == 1
        
        User.find_by_email('jeff@machovy.com').should_not be_nil
        User.find_by_email('jeff@machovy.com').is_customer?.should be_true
      end
      
      it "should have sent the email" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        msg.to.to_s.should match('jeff@machovy.com')
      end
      
      it "should have the right subject" do
        msg.subject.should == I18n.t('devise.mailer.confirmation_instructions.subject')
      end
      
      it "should have the right content" do
        #msg.body.encoded.should match('Please see the attachment for our standard Vendor agreement')
        msg.body.encoded.should match('Welcome jeff@machovy.com!')
        ActionMailer::Base.deliveries.count.should == 1
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      describe "Confirmation" do
        before { visit user_confirmation_path(:confirmation_token => User.find_by_email('jeff@machovy.com').confirmation_token) }
        
        it { should have_content(I18n.t('devise.confirmations.confirmed')) }
        it { should have_link(I18n.t('my_orders')) }
      end
    end
  end
end
