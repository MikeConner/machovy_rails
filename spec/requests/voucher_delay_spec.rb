describe "Order promotion with voucher limit" do
  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:promotion_with_delay_and_vouchers, :vendor => @vendor) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::MERCHANT)
    @vendor = FactoryGirl.create(:vendor, :user => user)
    user.roles << Role.find_by_name(Role::MERCHANT)
    visit root_path
    Warden.test_mode!
  end

  subject { page }

  describe "Sign in", :js => true do
    before do
      login_as(promotion.vendor.user, :scope => :user)
      visit merchant_vouchers_path
      fill_in 'voucher_search', :with => "#{promotion.vouchers.first.uuid}\n"
    end

    it "should have a delay" do
      promotion.vouchers.first.delay_hours.should be == 6
    end
    
    describe "should not be redeemable" do
      it { should_not have_link('Redeem', :href => redeem_admin_merchant_voucher_path(promotion.vouchers.first, :status => Voucher::REDEEMED)) }
      it { should have_content('Cannot redeem until') }      
    end
  end
end
