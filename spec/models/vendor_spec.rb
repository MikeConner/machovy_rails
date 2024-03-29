# == Schema Information
#
# Table name: vendors
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  url             :string(255)
#  facebook        :string(255)
#  phone           :string(255)
#  address_1       :string(255)
#  address_2       :string(255)
#  city            :string(255)
#  state           :string(255)
#  zip             :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  latitude        :decimal(, )
#  longitude       :decimal(, )
#  slug            :string(255)
#  private_address :boolean          default(FALSE)
#  source          :string(255)
#  logo_image      :string(255)
#  notes           :string(255)
#

describe "Vendors" do
  include ApplicationHelper
  
  let(:user) { FactoryGirl.create(:user) }
  let(:vendor) { FactoryGirl.create(:vendor, :user => user) }
  
  subject { vendor }
  
  it "should respond to everything" do
    vendor.should respond_to(:address_1)
    vendor.should respond_to(:address_2)
    vendor.should respond_to(:city)
    vendor.should respond_to(:facebook)
    vendor.should respond_to(:name)
    vendor.should respond_to(:phone)
    vendor.should respond_to(:state)
    vendor.should respond_to(:url)
    vendor.should respond_to(:zip)
    vendor.should respond_to(:promotions)
    vendor.should respond_to(:metros)
    vendor.should respond_to(:orders)
    vendor.should respond_to(:total_paid)
    vendor.should respond_to(:amount_owed)
    vendor.should respond_to(:total_commission)
    vendor.should respond_to(:latitude)
    vendor.should respond_to(:longitude)
    vendor.should respond_to(:mappable?)
    vendor.should respond_to(:map_address)
    vendor.should respond_to(:facebook_display)
    vendor.should respond_to(:private_address)
    vendor.should respond_to(:source)
    vendor.should respond_to(:coupons)
    vendor.should respond_to(:logo_image)
    vendor.should respond_to(:time_owed)
    vendor.should respond_to(:notes)
    vendor.user.should be == user
  end
  
  it { should be_valid }

  describe "automatic geocoding" do
    let(:vendor) { FactoryGirl.create(:vendor_with_known_address) }
    
    it "should be properly geocoded" do
      vendor.latitude.round(2).should be == 33.64
      vendor.longitude.round(2).should be == -84.44
    end
  end
  
  it "should not have time owed" do
    (Time.zone.now - vendor.time_owed).round(1).should be == 0
  end
  
  describe "time owed" do
    let(:vendor) { FactoryGirl.create(:vendor_with_vouchers) }
    before { vendor.vouchers.first.update_attributes!(:redemption_date => 1.week.ago, :status => Voucher::REDEEMED) }
    
    it "should have the right time owed" do
      vendor.time_owed.to_s.should be == 1.week.ago.to_s
    end
  end
  
  describe "coupons" do
    let(:vendor) { FactoryGirl.create(:vendor_with_coupons) }
    
    it "should have coupons" do
      vendor.coupons.count.should be == 2
      vendor.coupons.each do |coupon|
        coupon.vendor.should be == vendor
      end
    end
    
    describe "should be able to delete" do
      before { vendor.destroy }
      
      it "should delete the coupons" do
        Coupon.count.should be == 0
      end
    end
  end
  
  describe "invalid private address" do
    before { vendor.private_address = nil }
    
    it { should_not be_valid }
  end
  
  describe "name" do
    before { vendor.name = " " }
    
    it { should_not be_valid }
  end
  
  describe "address" do
    before { vendor.address_1 = " " }
    
    it { should_not be_valid }
  end
  
  describe "city" do
    before { vendor.city = "  "}
    
    it { should_not be_valid }
  end
  
  describe "state" do 
    before { vendor.state = " " }
    
    it { should_not be_valid }
    
    describe "validate against list" do
      ApplicationHelper::US_STATES.each do |state|
        before { vendor.state = state }
        
        it { should be_valid }
      end
      
      describe "invalid state" do
        before { vendor.state = "Not a state" }
        
        it { should_not be_valid }
      end
    end
  end

  describe "no zip code" do
    before { vendor.zip = nil }
    
    it { should_not be_valid }
  end
  
  describe "zip code (valid)" do
    ["13416", "15237", "15237-2339"].each do |code|
      before { vendor.zip = code }
      
      it { should be_valid }
    end
  end

  describe "zip code (invalid)" do  
    ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
      before { vendor.zip = code }
     
      it { should_not be_valid }
    end
  end  

  describe "phone (valid)" do
    ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
      before { vendor.phone = phone }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "phone (invalid)" do  
    ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
      before { vendor.phone = phone }
     
      it { should_not be_valid }
    end
  end  

  describe "missing phone" do
    before { vendor.phone = nil }
    
    it { should_not be_valid }
  end
  
  describe "url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { vendor.url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { vendor.url = url }
     
      it { should_not be_valid }
    end
  end  

  describe "facebook (valid)" do
    ["http://www.facebook.com/jeffrey.bennett.7737", "facebook.com/jeff.bennett.342", "www.facebook.com/jeffrey.bennett.3423"].each do |fb|
      before { vendor.facebook = fb }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "facebook (invalid)" do  
    ["xyz", "facebook", "https://www.facebook.com", "bookface.com/jeff.3423", "@jeff", "facebook/jeff"].each do |fb|
      before { vendor.facebook = fb }
     
      it { should_not be_valid }
    end
  end  

  describe "url display" do
    before { vendor.url = "microsoft.com" }
    
    it "should calculate the display" do
      url_display(vendor.url).should == "http://microsoft.com"
    end
    
    context "already prefixed" do
      before { vendor.url = "http://microsoft.com" }
      
      it "shouldn't change" do
        url_display(vendor.url).should == vendor.url
      end
    end
  end
  
  describe "facebook display" do
    before { vendor.facebook = "facebook.com/dude" }
    
    it "should calculate the display" do
      vendor.facebook_display.should == "http://facebook.com/dude"
    end
    
    context "already prefixed" do
      before { vendor.facebook = "http://facebook.com/dude" }
      
      it "shouldn't change" do
        vendor.facebook_display.should == vendor.facebook
      end
    end
  end
  
  describe "mapping" do
    let(:vendor) { FactoryGirl.create(:vendor_with_map) }
    
    it { should be_valid }
    
    it "should have mapping fields" do
      vendor.mappable?.should be_true
    end
    
    describe "No map if private" do
      before { vendor.private_address = true }
      
      it "should not show the map" do
        vendor.mappable?.should be_false
      end
    end
    
    describe "invalid lat/long" do
      before { vendor.latitude = 'abc' }
      
      it { should_not be_valid }
    end

    describe "invalid latitude" do
      before { vendor.latitude = 'abc' }
      
      it { should_not be_valid }
    end

    describe "invalid longitude" do
      before { vendor.longitude = 'abc' }
      
      it { should_not be_valid }
    end

    describe "needs both for mappable" do
      before { vendor.latitude = nil }
      
      it { should be_valid }
      it "should not be mappable" do
        vendor.mappable?.should be_false
      end
    end

    describe "needs both for mappable" do
      before { vendor.longitude = nil }
      
      it { should be_valid }
      it "should not be mappable" do
        vendor.mappable?.should be_false
      end
    end
  end
  
  describe "should allow deletion if no promotions" do
    it "should not have promotions" do
      vendor.promotions.count.should == 0
    end
    
    describe "delete" do
      before do
        @id = vendor.id
        vendor.destroy
      end
      
      it "should allow deletion" do
        expect { Vendor.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe "promotions" do
    let(:vendor) { FactoryGirl.create(:vendor_with_promotions, :user => user) }
    
    it { should be_valid }
        
    it "should have promotions" do
      vendor.promotions.count.should be == 5
      vendor.promotions.each do |p|
        p.vendor.should == vendor
      end
    end
    
    it "should have metros" do
      vendor.metros.count.should > 0
    end

    it "should not have orders" do
      vendor.orders.count.should == 0
    end
    
    describe "deleting the vendor doesn't delete promotions" do
      before { @id = vendor.id }
      
      it "shouldn't allow deletion" do
        expect { vendor.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Vendor.find(@id).should == vendor
      end
      
      it "should still have promotions" do
        Promotion.unscoped.reload.count.should be == 5
        Promotion.find_by_metro_id(@id).should_not be_nil
      end
    end    
  end
  
  describe "orders" do
    let(:vendor) { FactoryGirl.create(:vendor_with_orders, :user => user) }

    it { should be_valid }
        
    it "should have orders" do
      vendor.orders.count.should be == 25
      vendor.orders.each do |order|
        order.vendor.should == vendor
      end
    end

=begin    
    Remove this test now; since we have a vendor update without nested promotion attributes, we can't validate_associated :promotions
    describe "validate promotions" do
      before { vendor.reload.promotions[0].update_attributes(:retail_value => -1) }
      
      it { should_not be_valid }
    end
=end
        
    describe "deleting the vendor doesn't delete orders" do
      before { @id = vendor.id }
      
      it "shouldn't allow deletion" do
        expect { vendor.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Vendor.find(@id).should == vendor
      end
      
      it "should still have orders" do
        Order.unscoped.reload.count.should == 25
      end
    end 
    
    describe "deleting promotion doesn't delete orders" do
      before do
        @promotion = vendor.reload.promotions[0]
        @id = @promotion.id
      end
      
      it "shouldn't allow deletion" do
        expect { @promotion.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Promotion.find(@id).should == @promotion
      end
      
      it "should still have promotions" do
        Promotion.unscoped.reload.count.should be == 5
        Order.unscoped.reload.count.should == 25
      end
    end
     
    describe "deleting orders lets you delete promotions" do
      # Order.destroy_all does not work; don't ask me why
      before do
        vendor.reload.orders.each do |order|
          order.destroy
        end
      end
      
      it "should have promotions" do
        vendor.reload.promotions.count.should be == 5
        vendor.reload.promotions.each do |p|
          p.vendor.should == vendor
        end
      end

      it "should not have orders" do
        vendor.reload.orders.count.should == 0
      end
      
      describe "deleting promotions lets you delete the vendor" do
        before { Promotion.destroy_all }
        
        it "should not have promotions" do
          vendor.reload.promotions.count.should be == 0
          vendor.reload.orders.count.should == 0
        end
        
        describe "delete" do
          before do
            @id = vendor.id
            vendor.reload.destroy
          end
          
          it "should allow deletion" do
            expect { Vendor.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
          end
        end        
      end
    end   
  end
  
  describe "metros" do
    let(:metro1) { FactoryGirl.create(:metro) }
    let(:metro2) { FactoryGirl.create(:metro) }
    before { promotion1 = FactoryGirl.create(:promotion, :vendor => vendor, :metro => metro1) }
    
    it "should have the first metro" do
      vendor.metros.count.should be == 1
      vendor.metros[0].should == metro1
    end
    
    describe "Add another" do
      before { promotion2 = FactoryGirl.create(:promotion, :vendor => vendor, :metro => metro2) }
      
      it "should have both metros" do
        vendor.metros.count.should be == 2
        vendor.metros.sort.should == [metro1, metro2].sort
      end
      
      describe "Ensure uniqueness" do
        before { promotion3 = FactoryGirl.create(:promotion, :vendor => vendor, :metro => metro2) }
        
        it "should have two metros" do
          vendor.metros.count.should be == 2
          vendor.metros.sort.should == [metro1, metro2].sort
        end
      end
    end
  end

  describe "vouchers and payments" do
    let(:payment) { FactoryGirl.create(:payment, :vendor => vendor) }
    before do 
      payment
      FactoryGirl.create(:promotion_with_vouchers, :vendor => vendor)
    end
    
    it "should have vouchers" do
      Voucher.all.each do |voucher|
        voucher.promotion.vendor.should be == vendor
        voucher.paid?.should be_false
      end
    end
    
    it "should have payments" do
      vendor.payments.count.should be == 1
      vendor.payments.first.should == payment
    end
    
    it "should show amounts paid and owed" do
      vendor.total_paid.should be == payment.amount
      # 0 because the vouchers will all be available
      vendor.amount_owed.should be == 0
      vendor.total_commission.should == 0
    end
    
    describe "partial redemption, multiple quantities, etc" do
      let(:vendor) { FactoryGirl.create(:vendor) }
      let(:promotion) { FactoryGirl.create(:promotion, :vendor => vendor) }
      let(:order_multiple_unredeemed) { FactoryGirl.create(:order, :promotion => promotion, :quantity => 2) }
      let(:order_multiple_one_redeemed) { FactoryGirl.create(:order, :promotion => promotion, :quantity => 2) }
      let(:order_multiple_both_redeemed) { FactoryGirl.create(:order, :promotion => promotion, :quantity => 2) }
      before do
        order_multiple_unredeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now)
        order_multiple_unredeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now)
        order_multiple_one_redeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now, :status => Voucher::REDEEMED)
        order_multiple_one_redeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now)
        order_multiple_both_redeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now, :status => Voucher::REDEEMED)
        order_multiple_both_redeemed.vouchers.create!(:valid_date => 3.days.ago, :expiration_date => 1.week.from_now, :status => Voucher::REDEEMED)
      end
      
      it "should have correct payments owed" do
        vendor.amount_owed.round(2).should be == order_multiple_both_redeemed.merchant_share.round(2)
      end
    end
    
    describe "redeem vouchers" do
      before do
        Voucher.update_all(:status => Voucher::REDEEMED)
        @total = 0
        @commission = 0
        Promotion.first.orders.each do |order|
          @total += order.merchant_share
          @commission += order.machovy_share
        end 
      end
      
      it "should show amounts paid and owed" do
        vendor.total_paid.should be == payment.amount
        vendor.amount_owed.round(4).should be == @total.round(4) # because the order has 3 vouchers
        vendor.total_commission.round(4).should == @commission.round(4)
      end 
      
      describe "mark paid" do
        before { 
          Voucher.all.each do |voucher|
            # not in accessible fields by design
            voucher.payment_id = payment.id
            voucher.save!
          end
        }
        
        it "should show amounts paid and owed" do
          vendor.total_paid.should be == payment.amount
          vendor.amount_owed.should be == 0        
          vendor.total_commission.should == 0  
        end
      end
    end
  end
end
