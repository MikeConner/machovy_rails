describe "Buy Gift Certificate for pending signup, then change" do
  VISA = '4242424242424242'

  let(:old_email) { FactoryGirl.generate(:random_email) }
  let(:target_email) { FactoryGirl.generate(:random_email) }
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
      let(:gift_given_msg) { ActionMailer::Base.deliveries[0] }
      let(:gift_received_msg) { ActionMailer::Base.deliveries[1] }
      before do
        fill_in :gift_certificate_email, :with => target_email
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        click_button I18n.t('buy_gift_certificate')
        # Go to dashboard; should show gift certificates
        visit merchant_vouchers_path
        #save_page # Seem to need this for timing!
        @certificate = GiftCertificate.first
      end
            
      it "should have created the bucks recipient" do
        GiftCertificate.count.should be == 1
        GiftCertificate.pending.count.should be == 1
        GiftCertificate.redeemed.count.should be == 0
        @user.reload.gift_certificates.should be == [@certificate]
        @certificate.user.should be == @user
        @certificate.email.should be == target_email
        @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
        @certificate.charge_id.should_not be_nil
        @certificate.pending.should be_true 
        # Show show the pending gift certificate
        page.should have_selector('h1', :text => 'Pending Gift Certificates')
        page.should have_link('Change email')
        ActionMailer::Base.deliveries.count.should be == 2
        gift_given_msg.subject.should be == UserMailer::GIFT_GIVEN_MESSAGE
        gift_received_msg.subject.should be == UserMailer::GIFT_RECEIVED_MESSAGE
        gift_given_msg.to.to_s.should match(@user.email)
        gift_received_msg.to.to_s.should match(target_email)
      end
      
      describe "Buyer changes email to existing user", :js => true do
        let(:gift_given_user_msg) { ActionMailer::Base.deliveries[2] }
        let(:gift_credited_msg) { ActionMailer::Base.deliveries[3] }
        before do
          FactoryGirl.create(:user, :email => old_email)
          click_link 'Change email'
          fill_in 'gift_certificate_email', :with => old_email
          click_button 'Update Gift Certificate'
          save_page
          @certificate = GiftCertificate.first
        end
        
        it "should have credited the macho bucks and sent the emails" do
          ActionMailer::Base.deliveries.count.should be == 4
          gift_given_user_msg.subject.should be == UserMailer::GIFT_GIVEN_MESSAGE
          gift_credited_msg.subject.should be == UserMailer::GIFT_CREDITED_MESSAGE
          gift_given_user_msg.to.to_s.should match(@user.email)
          gift_credited_msg.to.to_s.should match(old_email)
          
          GiftCertificate.count.should be == 1
          GiftCertificate.pending.count.should be == 0
          GiftCertificate.redeemed.count.should be == 1
          @user.reload.gift_certificates.should be == [@certificate]
          @certificate.user.should be == @user
          @certificate.email.should be == old_email
          @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
          @certificate.charge_id.should_not be_nil
          @certificate.pending.should be_false
          MachoBuck.count.should be == 1
          User.find_by_email(old_email).total_macho_bucks.should be == GiftCertificate::DEFAULT_AMOUNT     
        end        
      end
      
      describe "Buyer changes email to another one that didn't sign up yet", :js => true do
        let(:gift_update_msg) { ActionMailer::Base.deliveries[2] }
        before do
          # Don't create user with old_email
          click_link 'Change email'
          fill_in 'gift_certificate_email', :with => old_email
          click_button 'Update Gift Certificate'
          save_page
          @certificate = GiftCertificate.first
        end
        
        it "should have credited the macho bucks and sent the emails" do
          ActionMailer::Base.deliveries.count.should be == 3
          gift_update_msg.subject.should be == UserMailer::GIFT_UPDATE_MESSAGE
          gift_update_msg.to.to_s.should match(@user.email)
          gift_update_msg.cc.to_s.should match(target_email)
          gift_update_msg.cc.to_s.should match(old_email)
          
          GiftCertificate.count.should be == 1
          GiftCertificate.pending.count.should be == 1
          GiftCertificate.redeemed.count.should be == 0
          @user.reload.gift_certificates.should be == [@certificate]
          @certificate.user.should be == @user
          @certificate.email.should be == old_email
          @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
          @certificate.charge_id.should_not be_nil
          @certificate.pending.should be_true
          MachoBuck.count.should be == 0
          @user.reload.total_macho_bucks.should be == 0   
        end        
      end
    end
  end
end
