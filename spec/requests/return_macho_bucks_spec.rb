describe "Return macho bucks" do
  let(:dude) { FactoryGirl.create(:user) }
  let(:order) { FactoryGirl.create(:order_with_vouchers, :user => dude) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    visit root_path
  end
  
  subject { page }
  
  describe "Sign in as an admin" do
    before do
      sign_in_as_an_admin_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      @voucher = order.reload.vouchers.first
    end
    
    it "should have no macho bucks" do
      dude.total_macho_bucks.should be == 0
      MachoBuck.count.should be == 0
    end
    
    describe "Find voucher", :js => true do
      before do
        visit merchant_vouchers_path
        fill_in 'voucher_search', :with => "#{@voucher.uuid}\n" 
      end
      
      it { should have_xpath("//form[@action='#{redeem_admin_merchant_voucher_path(@voucher)}']") }
      it { should have_content(@voucher.uuid) }
      it { should have_content(Voucher::AVAILABLE) }
      
      describe "Return the voucher" do
        before do
          fill_in 'notes', :with => 'Notes on this return'
          click_button 'Return'
          page.driver.browser.switch_to.alert.accept
        end
        
        describe "Go back; the form should not be there" do
          before do
            visit merchant_vouchers_path
            fill_in 'voucher_search', :with => "#{@voucher.uuid}\n"
            @buck = MachoBuck.first
          end 
          
          it "should have a positive balance now" do
            MachoBuck.count.should be == 1
            @buck.notes.should be == 'Notes on this return'
            @buck.amount.should be == @voucher.order.amount
            @buck.voucher.should be == @voucher
          end
        
          it { should_not have_xpath("//form[@action='#{redeem_admin_merchant_voucher_path(@voucher)}']") }
          it { should have_content(@voucher.uuid) }
          it { should have_content(Voucher::RETURNED) }
        end
        
        describe "Check on the adjustment page" do
          before do
            visit macho_bucks_path
            fill_in 'email', :with => dude.email
            click_button 'Search'
          end
          
          it { should have_selector('h4', :text => "#{I18n.t('macho_bucks')} total: $#{dude.reload.total_macho_bucks.round(2)}") }
          it { should have_xpath("//form[@action='#{macho_bucks_path}']") }
          it { should have_selector('input', :value => "Adjust Macho Bucks") }
          it { should have_content(@voucher.uuid) }
        end
      end
    end
  end
end
