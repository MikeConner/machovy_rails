describe "Buy Gift Certificate for existing user" do
  VISA = '4242424242424242'

  let(:recipient_user) { FactoryGirl.create(:user) }
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
    
    describe "Buy a gift certificate", :js => true do
      let(:gift_given_msg) { ActionMailer::Base.deliveries[0] }
      let(:gift_credited_msg) { ActionMailer::Base.deliveries[1] }
      before do
        fill_in :gift_certificate_email, :with => recipient_user.email
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
        GiftCertificate.pending.count.should be == 0
        GiftCertificate.redeemed.count.should be == 1
        @user.reload.gift_certificates.should be == [@certificate]
        @certificate.user.should be == @user
        @certificate.email.should be == recipient_user.email
        @certificate.amount.should be == GiftCertificate::DEFAULT_AMOUNT
        @certificate.transaction_id.should_not be_nil
        @certificate.pending.should be_false
        ActionMailer::Base.deliveries.count.should be == 2
        gift_given_msg.subject.should be == UserMailer::GIFT_GIVEN_MESSAGE
        gift_credited_msg.subject.should be == UserMailer::GIFT_CREDITED_MESSAGE
        gift_given_msg.to.to_s.should match(@user.email)
        gift_credited_msg.to.to_s.should match(recipient_user.email)
        MachoBuck.count.should be == 1
        recipient_user.reload.total_macho_bucks.should be == GiftCertificate::DEFAULT_AMOUNT
      end      
    end
  end
end
