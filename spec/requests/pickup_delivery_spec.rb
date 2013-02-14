describe "Product promotion order view" do
  let(:vendor) { FactoryGirl.create(:vendor) }
  let(:foreign_vendor) { FactoryGirl.create(:vendor) }
  let(:non_product) { FactoryGirl.create(:promotion) }
   
  before do
    # Need this for visit root_path to work
    Metro.create(:name => 'Pittsburgh')
    Role.create(:name => Role::MERCHANT)    
    visit root_path
  end

  subject { page }
  
  describe "Correct vendor" do
    before do
      sign_in_as_a_vendor
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      @delivery = FactoryGirl.create(:product_promotion_with_order, :vendor => @vendor)
      @pickup = FactoryGirl.create(:product_pickup_promotion_with_order, :vendor => @vendor)
      # Authenticate
      click_button I18n.t('sign_in')
      visit show_payments_merchant_vendor_path(@vendor)
    end
 
    it { should have_content(@delivery.title) }
    it { should have_content(@pickup.title) }
    it { should have_link('Show Orders') }
    
    describe "Show delivery" do
      before { visit product_view_promotion_path(@delivery) }
      
      it { should have_content(@delivery.orders.first.shipping_address) }
    end
  
    describe "Show pickup" do
      before { visit product_view_promotion_path(@pickup) }
      
      it { should have_content(@pickup.orders.first.shipping_address) }
      it { should have_content(@pickup.orders.first.pickup_notes) }
    end
  end

  describe "Wrong vendor" do
    before do
      click_link I18n.t('sign_in_register')
      # fill in info
      fill_in 'user_email', :with => vendor.user.email
      fill_in 'user_password', :with => vendor.user.password
      @delivery = FactoryGirl.create(:product_promotion_with_order, :vendor => foreign_vendor)
      # Authenticate
      click_button I18n.t('sign_in')
      visit show_payments_merchant_vendor_path(foreign_vendor)
    end
    
    it { should_not have_content(@delivery.title) }
    
    describe "Try to see somebody else's list" do
      before { visit product_view_promotion_path(@delivery) }

      it { should have_content(I18n.t('foreign_promotion')) }      
    end

    describe "Try to see a non-product" do
      before { visit product_view_promotion_path(non_product) }

      it { should have_content(I18n.t('foreign_promotion')) }      
    end
  end
end