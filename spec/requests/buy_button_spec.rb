describe "Buy button rules" do
  let(:promotion) { FactoryGirl.create(:approved_promotion) }
  let(:promotion_with_orders) { FactoryGirl.create(:promotion_with_vouchers, :status => Promotion::MACHOVY_APPROVED) }
  let(:pending_promotion) { FactoryGirl.create(:approved_promotion, :pending => true) }
  let(:locked_promotion) { FactoryGirl.create(:approved_promotion, :requires_prior_purchase => true) }
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::MERCHANT)
    # Have to create this or I get RecordNotSaved errors
    promotion_with_orders
    visit root_path
  end

  subject { page }

  it "should be a zombie" do
    promotion_with_orders.zombie?.should be_true
    promotion.displayable?.should be_true
  end

  describe "Trying to buy zombie" do
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(promotion_with_orders)
    end
        
    it { should have_selector('h3', :text => promotion_with_orders.title) }
    #it { should have_selector('p', :text => I18n.t('sold_out')) }
    it { should_not have_link(I18n.t('click_to_buy')) }
  end

  describe "Trying to buy coming soon" do
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(pending_promotion)
    end
        
    it { should have_selector('h3', :text => pending_promotion.title) }
    #it { should have_selector('p', :text => I18n.t('coming_soon')) }
    it { should_not have_link(I18n.t('click_to_buy')) }
  end

  describe "Trying to buy locked promotion (requires prior purchase)" do
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(locked_promotion)
    end
        
    it { should have_selector('h3', :text => locked_promotion.title) }
    #it { should have_selector('p', :text => I18n.t('coming_soon')) }
    it { should_not have_link(I18n.t('click_to_buy')) }
    it { should have_content(I18n.t('unlock')) }
  end

  describe "Trying to buy locked promotion (requires prior purchase) -- when there is a purchase" do
    before do
      sign_in_as_a_valid_user
      FactoryGirl.create(:order, :user => @user)
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      visit promotion_path(locked_promotion)
    end
        
    it { should have_selector('h3', :text => locked_promotion.title) }
    #it { should have_selector('p', :text => I18n.t('coming_soon')) }
    it { should have_link(I18n.t('click_to_buy')) }
    it { should_not have_content(I18n.t('unlock')) }
  end

  describe "Not logged in" do
    before { visit promotion_path(promotion) }
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
    it { should_not have_selector('p', :text => I18n.t('sold_out')) }
  end

  describe "Logged in as an admin" do
    before do
      sign_in_as_an_admin_user
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
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
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
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
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
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
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      promotion.quantity = 100
      @order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3 + promotion_with_orders.vouchers.count
      @order.vouchers.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.displayable?.should be_true
      promotion.max_quantity_for_buyer(@user).should == ApplicationHelper::MAX_INT
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "Logged in as a regular user who bought three when the limit was four" do
    let(:promotion) { FactoryGirl.create(:approved_promotion, :max_per_customer => 4) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      @order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a max quantity of 4" do
      promotion.max_per_customer.should be == 4
      promotion.displayable?.should be_true
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3 + promotion_with_orders.vouchers.count
      @order.vouchers.each do |voucher|
        voucher.order.user.should be == @user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(@user).should == 1
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
  end

  describe "back door" do
    let(:user) { FactoryGirl.create(:user, :email => 'jeff@machovy.com') }
    let(:promotion_with_orders) { FactoryGirl.create(:promotion_with_vouchers, :status => Promotion::MACHOVY_APPROVED) }
    before do
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(user.email)
      all('#user_password')[0].set(user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      @order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => user)
      visit promotion_path(promotion)
    end
    
    it "should show that he bought some" do
      user.email.should be == 'jeff@machovy.com'
      Voucher.count.should be == 3 + promotion_with_orders.vouchers.count
      @order.vouchers.each do |voucher|
        voucher.order.user.should be == user
        voucher.order.promotion.should == promotion
      end
      
      promotion.max_quantity_for_buyer(user).should == ApplicationHelper::MAX_INT
    end
    
    it { should have_selector('h3', :text => promotion.title) }
    it { should have_link(I18n.t('click_to_buy'), :href => order_promotion_path(promotion)) }
    it { should_not have_content(I18n.t('nice_try')) }
  end

  describe "Logged in as a regular user who bought three when the limit was three" do
    let(:promotion) { FactoryGirl.create(:approved_promotion, :max_per_customer => 3) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      @order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a max quantity of 3" do
      promotion.displayable?.should be_true
      promotion.max_per_customer.should == 3
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3 + promotion_with_orders.vouchers.count
      @order.vouchers.each do |voucher|
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
    let(:promotion) { FactoryGirl.create(:approved_promotion, :min_per_customer => 2, :max_per_customer => 4) }
    before do
      sign_in_as_a_valid_user
      # go to sign in page
      all('a', :text => I18n.t('sign_in_register')).first.click
      # fill in info
      all('#user_email')[0].set(@user.email)
      all('#user_password')[0].set(@user.password)
      # Authenticate
      click_button I18n.t('sign_in')
      @order = FactoryGirl.create(:order_with_vouchers, :promotion => promotion, :user => @user)
      visit promotion_path(promotion)
    end
    
    it "should show a quantity range" do
      promotion.min_per_customer.should be == 2
      promotion.max_per_customer.should be == 4
      promotion.displayable?.should be_true
    end
    
    it "should show that he bought some" do
      Voucher.count.should be == 3 + promotion_with_orders.vouchers.count
      @order.vouchers.each do |voucher|
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
