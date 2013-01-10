describe "Buy Gift Certificate for pending signup; recipient changes email to target" do
  VISA = '4242424242424242'

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
      visit new_gift_certificate_path 
    end
    
    it { should have_selector('h1', :text => 'Buy a Macho Bucks Gift Certificate') }
    it { should have_button(I18n.t('buy_gift_certificate')) }    
    
    # Buy a gift certificate for target_email (not a current user)
    # Then we want to change our email to the target, which should trigger gift certificate redemption on confirmation
    # Trick: Ideally we'd log out and in again as a user, but I'm having trouble getting log outs to work
    #   So change *our* (logged in user's) email. However, since we also ordered the gift certificate, this would 
    #   fail because you can't gift yourself. To get around this, change the certificate's "user" owner to a newly
    #   created user.
    describe "Buy a gift certificate", :js => true do
      let(:gift_given_msg) { ActionMailer::Base.deliveries[0] }
      let(:gift_received_msg) { ActionMailer::Base.deliveries[1] }
      before do
        fill_in :gift_certificate_email, :with => target_email
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
        @certificate.email.should be == target_email
        @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
        @certificate.transaction_id.should_not be_nil
        @certificate.pending.should be_true 
        # Show show the pending gift certificate
        ActionMailer::Base.deliveries.count.should be == 2
        gift_given_msg.subject.should be == UserMailer::GIFT_GIVEN_MESSAGE
        gift_received_msg.subject.should be == UserMailer::GIFT_RECEIVED_MESSAGE
        gift_given_msg.to.to_s.should match(@user.email)
        gift_received_msg.to.to_s.should match(target_email)
      end
      
      describe "Recipient changes email", :js => true do
        let(:confirmed_msg) { ActionMailer::Base.deliveries[2] }
        let(:gift_redeemed_msg) { ActionMailer::Base.deliveries[3] }
        let(:gift_credited_msg) { ActionMailer::Base.deliveries[4] }
        let(:distractor_user) { FactoryGirl.create(:user) }
        before do
          @certificate = GiftCertificate.first
          @certificate.user_id = distractor_user.id
          @certificate.save!
          # Now change our email
          @user.reload.update_attributes(:email => target_email)
          # Need to confirm
          visit user_confirmation_path(:confirmation_token => @user.reload.confirmation_token)          
          save_page
          @certificate = GiftCertificate.first
        end
        
        it "should have credited the macho bucks and sent the emails" do
          ActionMailer::Base.deliveries.count.should be == 5
          confirmed_msg.subject.should be == I18n.t('devise.mailer.confirmation_instructions.subject')
          gift_redeemed_msg.subject.should be == UserMailer::GIFT_REDEEMED_MESSAGE
          gift_credited_msg.subject.should be == UserMailer::GIFT_CREDITED_MESSAGE
          confirmed_msg.to.to_s.should match(target_email)
          gift_redeemed_msg.to.to_s.should match(distractor_user.email)
          gift_credited_msg.to.to_s.should match(target_email)
          
          GiftCertificate.count.should be == 1
          GiftCertificate.pending.count.should be == 0
          GiftCertificate.redeemed.count.should be == 1
          @user.reload.gift_certificates.should be == []
          distractor_user.gift_certificates.should be == [@certificate]
          @certificate.user.should be == distractor_user
          @certificate.email.should be == target_email
          @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
          @certificate.transaction_id.should_not be_nil
          @certificate.pending.should be_false
          MachoBuck.count.should be == 1
          @user.reload.total_macho_bucks.should be == GiftCertificate::DEFAULT_AMOUNT     
        end        
      end
    end
  end
end
