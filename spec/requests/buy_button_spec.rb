describe "Buy button rules" do
  let(:promotion) { FactoryGirl.create(:promotion) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    visit root_path
  end

  subject { page }

  describe "Not logged in" do
    before { visit promotion_path(promotion) }
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "Logged in as an admin" do
    before do
      sign_in_as_an_admin_user
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(promotion)
    end
    
    it "should be an admin" do
      @user.has_role?(Role::SUPER_ADMIN).should be_true
    end
    it { should have_selector('h3', :text => promotion.title) }
    it { should_not have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
    
    describe "should not be able to bypass" do
      before { visit order_promotion_path(promotion) }
      
      it { should have_content(I18n.t('nice_try')) }
      
      it "should stay on the page" do
        current_path.should == promotion_path(promotion)
      end
    end
  end
  
  describe "Logged in as a merchant" do
    before do
      sign_in_as_a_vendor
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(promotion)
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should_not have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
    
    describe "should not be able to bypass" do
      before { visit order_promotion_path(promotion) }
      
      it { should have_content(I18n.t('nice_try')) }
      
      it "should stay on the page" do
        current_path.should == promotion_path(promotion)
      end
    end
  end

  describe "Logged in as a regular user who didn't buy any" do
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(promotion)
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "Logged in as a regular user who bought some when it was unlimited" do
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3
      Voucher.all.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(@user).should == ApplicationHelper::MAX_INT
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "Logged in as a regular user who bought three when the limit was four" do
    let(:promotion) { FactoryGirl.create(:promotion, :max_per_customer => 4) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a max quantity of 4" do
      promotion.max_per_customer.should == 4
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3
      Voucher.all.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(@user).should == 1
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "Logged in as a regular user who bought three when the limit was three" do
    let(:promotion) { FactoryGirl.create(:promotion, :max_per_customer => 3) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a max quantity of 3" do
      promotion.max_per_customer.should == 3
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3
      Voucher.all.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(@user).should == 0
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should_not have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }

    describe "should not be able to bypass" do
      before { visit order_promotion_path(promotion) }
      
      it { should have_content(I18n.t('nice_try')) }
      
      it "should stay on the page" do
        current_path.should == promotion_path(promotion)
      end
    end
  end

  describe "Logged in as a regular user who bought three with a range of 2-4" do
    let(:promotion) { FactoryGirl.create(:promotion, :min_per_customer => 2, :max_per_customer => 4) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      # Authenticate
      click_button I18n.t('sign_in')
      order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a quantity range" do
      promotion.min_per_customer.should be == 2
      promotion.max_per_customer.should == 4
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3
      Voucher.all.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(@user).should == 1
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should_not have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
    
    describe "should not be able to bypass" do
      before { visit order_promotion_path(promotion) }
      
      it { should have_content(I18n.t('nice_try')) }
      
      it "should stay on the page" do
        current_path.should == promotion_path(promotion)
      end
    end
  end
end
