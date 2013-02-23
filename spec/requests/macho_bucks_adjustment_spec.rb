describe "Macho Bucks Admin Adjustments" do
  let(:bucks_user) { FactoryGirl.create(:user) }
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
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit macho_bucks_path
    end
    
    describe "Search for user" do
      before do
        fill_in 'email', :with => bucks_user.email
        click_button 'Search'
      end
      
      it { should have_selector('h4', :text => "#{I18n.t('macho_bucks')} total: $0.00") }
      it { should have_xpath("//form[@action='#{macho_bucks_path}']") }
      it { should have_button("Adjust Macho Bucks") }
      
      describe "Make an adjustment" do
        before do
          fill_in 'macho_buck_amount', :with => 25
          fill_in 'macho_buck_notes', :with => 'This is a test adjustment'
          click_button 'Adjust Macho Bucks'
          @bucks = MachoBuck.first
        end
        
        it "should stay on the page" do
          current_path.should be == macho_bucks_path
        end
          
        it { should have_selector('h4', :text => "#{I18n.t('macho_bucks')} total: $25.00") }
        
        it "should have the correct total" do
          bucks_user.reload.total_macho_bucks.to_i.should be == 25
          @bucks.user.should be == bucks_user
          @bucks.admin.should be == @user
          @bucks.amount.to_i.should be == 25
          @bucks.notes.should be == 'This is a test adjustment'
          MachoBuck.count.should == 1
        end
        
        describe "Zero it out" do
          before do
            fill_in 'macho_buck_amount', :with => -25
            fill_in 'macho_buck_notes', :with => 'This is a test zero'
            click_button 'Adjust Macho Bucks'
            @bucks = MachoBuck.first
            @zero = MachoBuck.last
          end
          
          it "should stay on the page" do
            current_path.should be == macho_bucks_path
          end
            
          it { should have_selector('h4', :text => "#{I18n.t('macho_bucks')} total: $0.00") }
          
          it "should have the correct total" do
            bucks_user.reload.total_macho_bucks.to_i.should be == 0
            @bucks.user.should be == bucks_user
            @bucks.admin.should be == @user
            @bucks.amount.to_i.should be == 25
            @bucks.notes.should be == 'This is a test adjustment'
            MachoBuck.count.should be == 2
            @zero.user.should be == bucks_user
            @zero.admin.should be == @user
            @zero.amount.to_i.should be == -25
            @zero.notes.should be == 'This is a test zero'
          end          
        end
      end
    end
  end  
end
