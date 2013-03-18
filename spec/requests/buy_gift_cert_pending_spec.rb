describe "Buy Gift Certificate for pending signup" do
  VISA = '4242424242424242'

  let(:recipient_email) { FactoryGirl.generate(:random_email) }
  
  before do
    Metro.create!(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
    Warden.test_mode!
  end

  subject { page }
  
  describe "Sign up" do
    before do
      sign_in_as_a_valid_user
      login_as(@user, :scope => :user)
=begin
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')   
=end
      visit new_gift_certificate_path 
    end
    
    it { should have_selector('h1', :text => 'Buy a Macho Bucks Gift Certificate') }
    it { should have_button(I18n.t('buy_gift_certificate')) }    
    
    describe "Buy a gift certificate", :js => true do
      before do
        fill_in 'gift_certificate_email', :with => recipient_email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        click_button I18n.t('buy_gift_certificate')
        save_page # Seem to need this for timing!
        @certificate = GiftCertificate.first
      end
            
      it "should have created the bucks recipient" do
        GiftCertificate.count.should be == 1
        GiftCertificate.pending.count.should be == 1
        GiftCertificate.redeemed.count.should be == 0
        @user.reload.gift_certificates.should be == [@certificate]
        @certificate.user.should be == @user
        @certificate.email.should be == recipient_email
        @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
        @certificate.transaction_id.should_not be_nil
        @certificate.pending.should be_true 
      end
      
      describe "Recipient signs up", :js => true do
        let(:gift_given_msg) { ActionMailer::Base.deliveries[0] }
        let(:gift_received_msg) { ActionMailer::Base.deliveries[1] }
        let(:confirmed_msg) { ActionMailer::Base.deliveries[2] }
        let(:gift_redeemed_msg) { ActionMailer::Base.deliveries[3] }
        let(:gift_credited_msg) { ActionMailer::Base.deliveries[4] }
        # Hokey way to run the signin. It doesn't let me log out. Create a user with a token so that
        let(:target_user) { FactoryGirl.create(:user, :email => recipient_email, :confirmed_at => nil) }
        before do
          # click_link 'Log out' fails with a Timeout for some reason, though it works in other integration tests...
          #click_link 'Log out'
          #logout(@user)
          #login_as(target_user, :scope => :user)
=begin     
          visit new_user_session_path
          within(".sign-up-block") do
            fill_in 'user_email', :with => recipient_email
            fill_in 'user_password', :with => "machoman"
          end
          fill_in 'user_password_confirmation', :with => "machoman"
          
          click_button I18n.t('create_account')
=end
          visit user_confirmation_path(:confirmation_token => target_user.confirmation_token)
          save_page
          @certificate = GiftCertificate.first
        end
        
        it "should have credited the macho bucks and sent the emails" do
          #ActionMailer::Base.deliveries.each do |msg|
          #  puts "#{msg.subject}, #{msg.to.to_s}"
          #end
          ActionMailer::Base.deliveries.count.should be == 5
          gift_given_msg.subject.should be == UserMailer::GIFT_GIVEN_MESSAGE
          gift_received_msg.subject.should be == UserMailer::GIFT_RECEIVED_MESSAGE
          gift_redeemed_msg.subject.should be == UserMailer::GIFT_REDEEMED_MESSAGE
          confirmed_msg.subject.should be == I18n.t('devise.mailer.confirmation_instructions.subject')
          gift_credited_msg.subject.should be == UserMailer::GIFT_CREDITED_MESSAGE
          gift_given_msg.to.to_s.should match(@user.email)
          gift_received_msg.to.to_s.should match(recipient_email)
          gift_redeemed_msg.to.to_s.should match(@user.email)
          confirmed_msg.to.to_s.should match(target_user.email)
          gift_credited_msg.to.to_s.should match(target_user.email)
          
          GiftCertificate.count.should be == 1
          GiftCertificate.pending.count.should be == 0
          GiftCertificate.redeemed.count.should be == 1
          @user.reload.gift_certificates.should be == [@certificate]
          @certificate.user.should be == @user
          @certificate.email.should be == recipient_email
          @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
          @certificate.transaction_id.should_not be_nil
          @certificate.pending.should be_false
          MachoBuck.count.should be == 1
          User.find_by_email(recipient_email).total_macho_bucks.should be == GiftCertificate::DEFAULT_AMOUNT     
        end
      end
    end
  end
end
