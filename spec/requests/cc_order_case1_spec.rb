describe "Case 1 - not customer, order saving card" do
  VISA = '4242424242424242'

  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:approved_promotion) }
  let(:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    ActionMailer::Base.deliveries = []
    visit root_path
  end

  subject { page }

  describe "Sign in" do
    before do
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      save_page # for timing
      all('#user_email')[0].set(user.email)
      all('#user_password')[0].set(user.password)
      # Authenticate
      click_button I18n.t('sign_in')
    end

    it "user should not have a customer id" do
      user.customer_id.should be_nil
    end
    
    pending "Not a customer -- order saving card (case 1)", :js => true do
      let(:msg) { ActionMailer::Base.deliveries[0] }
      before do
        visit order_promotion_path(promotion)
        fill_in 'card_number', :with => VISA
        fill_in 'card_code', :with => '444'
        fill_in 'first_name', :with => 'Jeffrey'
        fill_in 'last_name', :with => 'Bennett'
        check 'cb_save_card'
        click_button I18n.t('buy_now')
      end

#TODO Replace with Vault
=begin      
      after do
        cu = Stripe::Customer.retrieve(user.reload.stripe_id)
        cu.delete
      end
=end            
      it "should work" do
        page.should_not have_content("RSpec timing issue???")
        order.reload.transaction_id.should_not be_nil
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should be == 1
        msg.to.to_s.should match(user.email)
        msg.subject.should be == UserMailer::ORDER_MESSAGE
        msg.body.encoded.should match('Thank you for your order')
        msg.body.encoded.should match('See attachments for your voucher')
        msg.attachments.count.should be == 1
        msg.attachments[0].filename.should == Voucher.first.uuid + ".png"
      end
      
      describe "Card should be saved" do
        before { visit order_promotion_path(promotion) }
                      
        it { should have_content "Use card with last 4 digits '#{VISA[-4..-1]}'" }
        it "should have a voucher" do
          Voucher.count.should == 1
        end
      end
    end
  end
end
