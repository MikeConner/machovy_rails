describe "Voucher Search" do
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::MERCHANT)
    @voucher = FactoryGirl.create(:voucher)
    visit root_path
  end

  subject { page }
  
  describe "Sign in" do
    before do
      sign_in_as_a_vendor
      # go to sign in page
      # Example of fix to ambiguous selector issues in Capybara 2.0; if you upgrade, have to make lots of things like this!
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
    end

    describe "search by email", :js => true do
      before do
        visit merchant_vouchers_path
        fill_in 'voucher_search', :with => "#{@voucher.order.user.email}\n"
      end
      
      it { should have_link('Redeem', :href => redeem_admin_merchant_voucher_path(@voucher, :status => Voucher::REDEEMED)) }
      it { should have_content(@voucher.uuid) }
    end
    
    describe "search by voucher", :js => true do
      before do
        visit merchant_vouchers_path
        fill_in 'voucher_search', :with => "#{@voucher.uuid}\n"
      end
      
      it { should have_link('Redeem', :href => redeem_admin_merchant_voucher_path(@voucher, :status => Voucher::REDEEMED)) }
      it { should have_content(@voucher.order.promotion.description) }
    end

    describe "search by voucher (inexact)", :js => true do
      before do
        visit merchant_vouchers_path
        tolerant_uuid = @voucher.uuid.gsub('-', ' ').upcase()
        fill_in 'voucher_search', :with => "#{tolerant_uuid}\n"
      end
      
      it { should have_link('Redeem', :href => redeem_admin_merchant_voucher_path(@voucher, :status => Voucher::REDEEMED)) }
      it { should have_content(@voucher.order.promotion.description) }
    end
    
    describe "search invalid voucher", :js => true do
      before do
        visit merchant_vouchers_path
        fill_in 'voucher_search', :with => "blah\n"
      end
      
      it "should display the voucher not found dialog" do
        page.driver.wait_until(alert = page.driver.browser.switch_to.alert)
        alert.text.should be == 'Voucher not found'
        alert.accept()
      end
    end
  end
end
