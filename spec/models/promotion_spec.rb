# == Schema Information
#
# Table name: promotions
#
#  id                   :integer         not null, primary key
#  title                :string(255)
#  description          :text
#  limitations          :text
#  voucher_instructions :text
#  teaser_image         :string(255)
#  retail_value         :decimal(, )
#  price                :decimal(, )
#  revenue_shared       :decimal(, )
#  quantity             :integer
#  start_date           :datetime
#  end_date             :datetime
#  grid_weight          :integer
#  destination          :string(255)
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  slug                 :string(255)
#  status               :string(16)      default("Proposed"), not null
#  promotion_type       :string(16)      default("Deal"), not null
#  subtitle             :string(255)
#  strategy_id          :integer
#  strategy_type        :string(255)
#  min_per_customer     :integer         default(1), not null
#  max_per_customer     :integer         default(0), not null
#  suspended            :boolean         default(FALSE), not null
#  venue_address        :string(50)
#  venue_city           :string(50)
#  venue_state          :string(2)
#  venue_zipcode        :string(10)
#  latitude             :decimal(, )
#  longitude            :decimal(, )
#

describe "Promotions" do
  let(:metro) { FactoryGirl.create(:metro) }
  let(:vendor) { FactoryGirl.create(:vendor) }
  let(:promotion) { FactoryGirl.create(:promotion, :metro => metro, :vendor => vendor) }
  
  subject { promotion }

  it "should respond to everything" do
    promotion.should respond_to(:description)
    promotion.should respond_to(:destination)
    promotion.should respond_to(:grid_weight)
    promotion.should respond_to(:limitations)
    promotion.should respond_to(:price)
    promotion.should respond_to(:quantity)
    promotion.should respond_to(:retail_value)
    promotion.should respond_to(:revenue_shared)
    promotion.should respond_to(:start_date)
    promotion.should respond_to(:end_date)
    promotion.should respond_to(:teaser_image)
    promotion.should respond_to(:remote_teaser_image_url)
    promotion.should respond_to(:main_image)
    promotion.should respond_to(:remote_main_image_url)
    promotion.should respond_to(:status)
    promotion.should respond_to(:promotion_type)
    promotion.should respond_to(:title)
    promotion.should respond_to(:voucher_instructions)
    promotion.should respond_to(:orders)
    promotion.should respond_to(:vouchers)
    promotion.should respond_to(:promotion_logs)
    promotion.should respond_to(:promotion_images)
    promotion.should respond_to(:categories)
    promotion.should respond_to(:blog_posts)
    promotion.should respond_to(:approved?)
    promotion.should respond_to(:expired?)
    promotion.should respond_to(:displayable?)
    promotion.should respond_to(:ad?)
    promotion.should respond_to(:affiliate?)
    promotion.should respond_to(:deal?)
    promotion.should respond_to(:remaining_quantity)
    promotion.should respond_to(:awaiting_vendor_action?)
    promotion.should respond_to(:awaiting_machovy_action?)
    promotion.should respond_to(:expired?)
    promotion.should respond_to(:open_vouchers?)
    promotion.should respond_to(:num_open_vouchers)
    promotion.should respond_to(:quantity_description)
    promotion.should respond_to(:discount)
    promotion.should respond_to(:discount_pct)
    promotion.should respond_to(:under_quantity_threshold?)
    promotion.should respond_to(:subtitle)
    promotion.should respond_to(:padded_description)
    promotion.should respond_to(:started?)
    promotion.should respond_to(:min_per_customer)
    promotion.should respond_to(:max_per_customer)
    promotion.should respond_to(:max_quantity_for_buyer)
    promotion.should respond_to(:suspended)
    promotion.should respond_to(:zombie?)
    promotion.should respond_to(:revenue_share_options)
    promotion.should respond_to(:product_order?)
    promotion.should respond_to(:pickup_order?)
    promotion.should respond_to(:shipping_address_required?)
    promotion.should respond_to(:venue_address)
    promotion.should respond_to(:venue_city)
    promotion.should respond_to(:venue_state)
    promotion.should respond_to(:venue_zipcode)
    promotion.should respond_to(:latitude)
    promotion.should respond_to(:longitude)
    promotion.should respond_to(:mappable?)
    promotion.should respond_to(:venue_location)
    promotion.metro.should be == metro
    promotion.vendor.should be == vendor
    promotion.promotion_type.should be == Promotion::LOCAL_DEAL
    promotion.status.should be == Promotion::PROPOSED
  end

  it { should be_valid }
  
  it "should default to correct settings" do
    promotion.displayable?.should be_false
    promotion.zombie?.should be_false
  end
  
  describe "mapping" do
    let(:promotion) { FactoryGirl.create(:promotion_with_map) }
    
    it { should be_valid }
    
    it "should have the address" do
      promotion.venue_location.should_not be_blank
    end
    
    it "should have mapping fields" do
      promotion.mappable?.should be_true
    end

    describe "invalid lat/long" do
      before { promotion.latitude = 'abc' }
      
      it { should_not be_valid }
    end
  
    describe "invalid latitude" do
      before { promotion.latitude = 'abc' }
      
      it { should_not be_valid }
    end
  
    describe "invalid longitude" do
      before { promotion.longitude = 'abc' }
      
      it { should_not be_valid }
    end
  
    describe "needs both for mappable" do
      before { promotion.latitude = nil }
      
      it { should be_valid }
      it "should not be mappable" do
        promotion.mappable?.should be_false
      end
    end
  
    describe "needs both for mappable" do
      before { promotion.longitude = nil }
      
      it { should be_valid }
      it "should not be mappable" do
        promotion.mappable?.should be_false
      end
    end
  end
  
  describe "address" do
    before { promotion.venue_address = " " }
    
    it { should be_valid }
  end
  
  describe "address too long" do
    before { promotion.venue_address = "a"*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "city" do
    before { promotion.venue_city = "  "}
    
    it { should be_valid }
  end
  
  describe "state" do 
    before { promotion.venue_state = " " }
    
    it { should be_valid }
    
    describe "validate against list" do
      ApplicationHelper::US_STATES.each do |state|
        before { promotion.venue_state = state }
        
        it { should be_valid }
      end
      
      describe "invalid state" do
        before { promotion.venue_state = "Not a state" }
        
        it { should_not be_valid }
      end
    end
  end

  describe "no zip code" do
    before { promotion.venue_zipcode = nil }
    
    it { should be_valid }
  end
  
  describe "zip code (valid)" do
    ["13416", "15237", "15237-2339"].each do |code|
      before { promotion.venue_zipcode = code }
      
      it { should be_valid }
    end
  end

  describe "zip code (invalid)" do  
    ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
      before { promotion.venue_zipcode = code }
     
      it { should_not be_valid }
    end
  end  
  
  describe "venue address" do
    let(:promotion) { FactoryGirl.create(:promotion_with_venue_address) }
    
    it { should be_valid }
    
    it "should have an address" do
      promotion.venue_address.should_not be_blank
      promotion.venue_city.should_not be_blank
      promotion.venue_state.should_not be_blank
      promotion.venue_zipcode.should_not be_blank
      promotion.venue_location.should_not be_blank
    end
  end
  
  describe "product promotion (delivery)" do
    let(:promotion) { FactoryGirl.create(:product_promotion) }
    
    it "should be a product" do
      promotion.product_order?.should be_true
      promotion.shipping_address_required?.should be_true
      promotion.pickup_order?.should be_false
    end
  end
  
  describe "product promotion (pickup)" do
    let(:promotion) { FactoryGirl.create(:product_pickup_promotion) }
    
    it "should be a product" do
      promotion.product_order?.should be_true
      promotion.shipping_address_required?.should be_false
      promotion.pickup_order?.should be_true
    end
  end
  
  describe "Zombie cases" do
    let(:ad) { FactoryGirl.create(:ad) }
    let(:expired_ad) { FactoryGirl.create(:ad, :end_date => 3.days.ago) }
    let(:affiliate) { FactoryGirl.create(:affiliate) }
    let(:promotion) { FactoryGirl.create(:promotion, :status => Promotion::MACHOVY_APPROVED) }
    let(:long_expired) { FactoryGirl.create(:promotion, :status => Promotion::MACHOVY_APPROVED, :end_date => 3.months.ago) }
    let(:just_expired) { FactoryGirl.create(:promotion, :status => Promotion::MACHOVY_APPROVED, :end_date => 3.days.ago) }
    let(:promotion_with_orders) { FactoryGirl.create(:promotion_with_vouchers, :status => Promotion::MACHOVY_APPROVED) }
    
    it "should have correct settings" do
      ad.displayable?.should be_true
      expired_ad.displayable?.should be_false
      affiliate.displayable?.should be_true
      promotion.displayable?.should be_true
      long_expired.displayable?.should be_false
      just_expired.displayable?.should be_false
      promotion_with_orders.displayable?.should be_false
      
      ad.zombie?.should be_false
      expired_ad.zombie?.should be_false
      affiliate.zombie?.should be_false
      promotion.zombie?.should be_false
      long_expired.zombie?.should be_false
      just_expired.zombie?.should be_true
      promotion_with_orders.zombie?.should be_true
    end
    
    describe "Promotion without image" do
      before { promotion.remove_teaser_image! }
      
      it "should not fail" do
        promotion.should be_valid
      end
    end

    describe "Ad without image" do
      before { ad.remove_teaser_image! }
      
      it "should fail" do
        ad.should_not be_valid
      end
    end

    describe "Affiliate without image" do
      before { affiliate.remove_teaser_image!  }
      
      it "should fail" do
        affiliate.should_not be_valid
      end
    end
  end
  
  describe "Missing suspended" do
    before { promotion.suspended = nil }
    
    it { should_not be_valid }
  end
  
  describe "Delete promotion should delete strategy" do
    before { promotion.destroy }
    
    it "should be gone" do
      Promotion.count.should be == 0
      FixedExpirationStrategy.count.should == 0
    end
  end
  
  describe "No strategy" do
    before { promotion.strategy = nil }
    
    it { should_not be_valid }
  end
    
  describe "Deleting strategy nullifies" do
    before { promotion.strategy.destroy }
    
    it "should be gone" do
      Promotion.count.should be == 1
      FixedExpirationStrategy.count.should be == 0
      promotion.reload.strategy.should be_nil
      promotion.reload.should_not be_valid
    end
  end
  
  describe "Invalid minimum/customer" do
    [0, -1, 0.5, 'abc', nil].each do |min|
      before { promotion.min_per_customer = min }
      
      it { should_not be_valid }
    end
  end

  describe "Valid minimum/customer" do
    [1, 5, 100, 2000].each do |min|
      before { promotion.min_per_customer = min }
      
      it { should be_valid }
    end
  end

  describe "Invalid maximum/customer" do
    # nil causes an exception in the voucher_limit_consistency
    # it's pathological, don't want to add a check for something that will never happen
    [-1, 0.5, 'abc'].each do |max|
      before { promotion.max_per_customer = max }
      
      it { should_not be_valid }
    end
  end
  
  describe "Valid maximum/customer" do
    [Promotion::UNLIMITED, 1, 5, 200, 5000].each do |max|
      before { promotion.max_per_customer = max }
      
      it { should be_valid }
    end
  end
  
  describe "Consistent min/max (equal)" do
    before { promotion.min_per_customer = promotion.max_per_customer = 2 }
    
    it { should be_valid }
  end
  
  describe "Consistent min/max (unequal)" do
    before do
      promotion.min_per_customer = 1
      promotion.max_per_customer = 4
    end
    
    it { should be_valid }
  end
  
  describe "Consistent min/max (unlimited)" do
    before do
      promotion.min_per_customer = 200
      promotion.max_per_customer = Promotion::UNLIMITED
    end
    
    it { should be_valid }
  end
  
  describe "Inconsistent min/max" do
    before do
      promotion.min_per_customer = 2
      promotion.max_per_customer = 1
    end
    
    it { should_not be_valid }
  end
  
  describe "padded description" do
    before { promotion.description = 'too short' }
    
    it "should pad it" do
      promotion.padded_description.should == "too short".ljust(Promotion::MIN_DESCRIPTION_LEN, ' ')
    end
    
    describe "exact len" do
      before { promotion.description = "a"*Promotion::MIN_DESCRIPTION_LEN }
      
      it "should match exactly" do
        promotion.description.should == promotion.padded_description
      end
      
      describe "already long enough" do
        before { promotion.description = "a"*(Promotion::MIN_DESCRIPTION_LEN * 2) }
        
        it "should not pad it" do
          promotion.description.should == promotion.padded_description          
        end
      end
    end
  end
  
  describe "initialization" do
    before { @promo = Promotion.new }
    
    it "should have a default weight" do
      @promo.grid_weight.should == Promotion::DEFAULT_GRID_WEIGHT
    end
  end
  
  describe "retail value (valid)" do
    [0, 2.5, 18].each do |v|
      before { promotion.retail_value = v }
      
      it { should be_valid }
    end
  end
  
  describe "retail value (invalid)" do   
    [-1, -1.25, 'abc', nil].each do |v|
      before { promotion.retail_value = v }
      
      it { should_not be_valid }
    end
  end

  describe "price (valid)" do
    [0, 2.5, 18].each do |p|
      before { promotion.price = p }
      
      it { should be_valid }
    end
  end
  
  describe "price (invalid)" do  
    [-1, -1.25, 'abc', nil].each do |p|
      before { promotion.price = p }
      
      it { should_not be_valid }
    end
  end

  describe "revenue shared (valid)" do
    [0, 2.5, 18].each do |r|
      before { promotion.revenue_shared = r }
      
      it { should be_valid }
    end
  end
  
  describe "revenue shared (invalid)" do  
    [-1, -1.25, 'abc', nil].each do |r|
      before { promotion.revenue_shared = r }
      
      it { should_not be_valid }
    end
  end
  
  describe "quantity (valid)" do
    [1, 5, 180].each do |q|
      before { promotion.quantity = q }
      
      it { should be_valid }
    end
  end
  
  describe "quantity (invalid)" do  
    [0, 1.5, -2, -1.25, 'abc', nil].each do |q|
      before { promotion.quantity = q }
      
      it { should_not be_valid }
    end
  end

  describe "grid_weight (valid)" do
    [1, 5, 180].each do |w|
      before { promotion.grid_weight = w }
      
      it { should be_valid }
    end
  end
  
  describe "grid_weight (invalid)" do  
    [0, 1.5, -2, -1.25, 'abc', nil].each do |w|
      before { promotion.grid_weight = w }
      
      it { should_not be_valid }
    end
  end
  
  describe "no description" do
    before { promotion.description = " " }
    
    it { should_not be_valid }
  end
  
  describe "no title" do
    before { promotion.title = " " }
    
    it { should_not be_valid }
  end
  
  describe "valid status" do 
    Promotion::PROMOTION_STATUS.each do |status|
      before { promotion.status = status }
      
      it { should be_valid }
    end
  end
  
  describe "invalid status" do
    [nil, "blah", "a"*(Promotion::MAX_STR_LEN + 1)].each do |status|
      before { promotion.status = status }
      
      it { should_not be_valid }
    end
  end

  describe "missing type" do
    before { promotion.promotion_type = nil }
    
    it { should_not be_valid }
  end  
  
  it "should be a deal" do
    promotion.deal?.should be_true
  end
  
  it "should not be an ad" do
    promotion.ad?.should be_false
  end
  
  it "should not be an affiliate" do
    promotion.affiliate?.should be_false
  end

  describe "Missing destination" do
    before { promotion.destination = " " }
    
    it { should be_valid }
  end

  it "should not have open vouchers" do
    promotion.open_vouchers?.should be_false
    promotion.num_open_vouchers.should == 0
  end

  describe "awaiting vendor action" do
    [Promotion::EDITED, Promotion::MACHOVY_REJECTED].each do |status|
      before { promotion.status = status }
      
      it "should be awaiting vendor action" do
        promotion.awaiting_vendor_action?.should be_true
        promotion.awaiting_machovy_action?.should be_false
        promotion.approved?.should be_false
      end
    end
  end

  describe "awaiting machovy action" do
    [Promotion::PROPOSED, Promotion::VENDOR_REJECTED].each do |status|
      before { promotion.status = status }
      
      it "should be awaiting vendor action" do
        promotion.awaiting_vendor_action?.should be_false
        promotion.awaiting_machovy_action?.should be_true
        promotion.approved?.should be_false
      end
    end
  end

  describe "status consistency" do
    Promotion::PROMOTION_STATUS.each do |status|
      before { promotion.status = status }
      
      it "should be consistent" do
        (promotion.awaiting_vendor_action?^promotion.awaiting_machovy_action?^promotion.approved?).should be_true
      end
    end
  end
  
  describe "ads" do
    let(:promotion) { FactoryGirl.create(:ad, :metro => metro, :vendor => vendor) }
    
    it { should respond_to(:destination) }
     
    it { should be_valid }

    it "should not have a strategy" do
      promotion.strategy.should be_nil
    end
    
    it "should not be a deal" do
      promotion.deal?.should be_false
    end
    
    it "should be an ad" do
      promotion.ad?.should be_true
    end
    
    it "should not be an affiliate" do
      promotion.affiliate?.should be_false
    end
  
    describe "Missing destination" do
      before { promotion.destination = " " }
      
      it { should_not be_valid }
    end
  end
    
  describe "affiliates" do
    let(:promotion) { FactoryGirl.create(:affiliate, :metro => metro, :vendor => vendor) }    
    
    it { should respond_to(:destination) }

    it { should be_valid }

    it "should not have a strategy" do
      promotion.strategy.should be_nil
    end
    
    it "should not be a deal" do
      promotion.deal?.should be_false
    end
    
    it "should not be an ad" do
      promotion.ad?.should be_false
    end
    
    it "should be an affiliate" do
      promotion.affiliate?.should be_true
    end
  
    describe "Missing destination" do
      before { promotion.destination = " " }
      
      it { should_not be_valid }
    end
  end
    
  describe "deletion" do
    it "should not have orders" do
      promotion.orders.count.should == 0
    end
    
    it "should allow deletion when there are no orders" do
      id = promotion.id
      expect { promotion.reload.destroy }.to_not raise_exception
      
      expect { Promotion.find(id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "orders" do
    let(:promotion) { FactoryGirl.create(:promotion_with_orders, :metro => metro, :vendor => vendor) }
        
    it { should be_valid}

    it "should have orders" do
      promotion.orders.count.should be == 5
      promotion.orders.each do |order|
        order.promotion.should == promotion
      end
    end
    
    describe "can't delete the promotion while there are orders" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with orders" do
        promotion.orders.count.should == 5
      end
      
      it "should not destroy associated orders" do
        orders = promotion.orders
        expect { promotion.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        
        orders.each do |order|
          Order.find_by_id(order.id).should_not be_nil
       end     
     end 
    end
  end
  
  it "should have all the vouchers remaining" do
    promotion.remaining_quantity.should == promotion.quantity
  end
  
  it "should not be approved" do
    promotion.approved?.should be_false
  end
  
  it "should not be displayable" do
    promotion.displayable?.should be_false
  end
  
  it "should be started" do
    promotion.started?.should be_true
  end
  
  it "should not be expired" do
    promotion.expired?.should be_false
  end

  describe "make it approved" do
    before { promotion.status = Promotion::MACHOVY_APPROVED }
    
    it "should be approved" do
      promotion.approved?.should be_true
    end
    
    it "should be displayable" do
      promotion.displayable?.should be_true
    end
    
    describe "Suspended" do
      before { promotion.suspended = true }
      
      it "should not be displayable" do
        promotion.displayable?.should be_false
      end
    end
    
    describe "no end date" do
      before { promotion.end_date = nil }
      
      it "should still be displayable" do
        promotion.displayable?.should be_true
      end
    end

    describe "no start date" do
      before { promotion.start_date = nil }
      
      it "should still be started" do
        promotion.started?.should be_true
      end
    end
    
    describe "Approved but not displayable" do
      before { promotion.end_date = 1.week.ago }
      
      it "should be approved" do
        promotion.approved?.should be_true
      end
      
      it "should be expired" do
        promotion.expired?.should be_true
      end
      
      it "should not have open vouchers" do
        promotion.open_vouchers?.should be_false
        promotion.num_open_vouchers.should == 0
      end
      
      it "should not be displayable" do
        promotion.displayable?.should be_false
      end
    end      
    
    describe "Approved but not displayable because future" do
      before { promotion.start_date = 2.weeks.from_now }
      
      it "should not be started" do
        promotion.started?.should be_false
      end
      
      it "should not be displayable" do
        promotion.displayable?.should be_false
      end
    end

    describe "Displayable with open vouchers" do
      let(:promotion) { FactoryGirl.create(:promotion_with_vouchers) }
      
      before do
        promotion.end_date = 1.week.ago
        promotion.status = Promotion::VENDOR_APPROVED
      end
      
      it "should be approved" do
        promotion.approved?.should be_true
      end
      
      it "should have open vouchers" do
        promotion.open_vouchers?.should be_true
        promotion.num_open_vouchers.should == 15
      end
      
      it "should be expired" do
        promotion.expired?.should be_true
      end
      
      it "should not be displayable (quantity)" do
        promotion.displayable?.should be_false
      end
      
      describe "add quantity to make displayable" do
        before { promotion.quantity = 100 }
        
        it "should be displayable (quantity)" do
          promotion.displayable?.should be_true
        end
      end
    end      
  end
  
  describe "discount (no retail)" do
    before { promotion.retail_value = nil }
    
    it "should be zero" do
      promotion.discount.should == 0
    end
  end
  
  describe "discount (no price)" do
    before { promotion.price = nil }
    
    it "should be zero" do
      promotion.discount.should == 0
    end
  end
  
  describe "discount (normal)" do
    before do
      promotion.retail_value = 1000
      promotion.price = 500
    end
    
    it "should be the difference" do
      promotion.discount.should be == 500
      promotion.discount_pct.should == 50
    end
  end
  
  describe "discount (capped)" do
    before do
      promotion.retail_value = 100
      promotion.price = 500
    end
    
    it "should not go negative" do
      promotion.discount.should be == 0
      promotion.discount_pct.should == 0
    end
  end

  describe "test remaining vouchers" do
    let(:promotion) { FactoryGirl.create(:promotion_with_vouchers) }    
    before { promotion.quantity = 20 }

    it "should have quantity - vouchers" do
      promotion.vouchers.count.should be == 15
      promotion.num_open_vouchers.should be == 15
      promotion.quantity.should be == 20
      promotion.remaining_quantity.should == 5
    end
    
    it "should not meet display threshold" do
      promotion.quantity_description.should be == I18n.t('plenty', :date => promotion.end_date.try(:strftime, ApplicationHelper::DATE_FORMAT))
      promotion.under_quantity_threshold?.should be_false
    end
    
    describe "force threshold" do
      before { promotion.quantity = 16 }
      
      it "should display x left" do
        promotion.under_quantity_threshold?.should be_true
        promotion.quantity_description.should == I18n.t('only_n_left', :n => 1)
      end
    end
    
    describe "most used" do
      before { promotion.quantity = 20 }
      
      it "should have some left" do
        promotion.remaining_quantity.should == 5
      end
    end
    
    describe "can't be negative (invalid quantity)" do
      before { promotion.quantity = 10 }
      
      it "should say one instead of negative" do
        promotion.remaining_quantity.should be == 1
        promotion.under_quantity_threshold?.should be_true
      end
    end
    
    describe "can't be negative (nil)" do
      before { promotion.quantity = nil }
      
      it "should say max int when nil" do
        promotion.remaining_quantity.should be == ApplicationHelper::MAX_INT
        promotion.under_quantity_threshold?.should be_false
      end
    end

    describe "can't be negative" do
      before { promotion.quantity = -10 }
      
      it "should say max int when nil" do
        promotion.remaining_quantity.should be == 1
        promotion.under_quantity_threshold?.should be_true
      end
    end
  end
  
  describe "scopes" do
    before do
      Promotion.destroy_all
      @promotions = FactoryGirl.create_list(:promotion, 10)
      # No more default scope, so need to order them
      @weights = Promotion.order(:grid_weight).map { |n| n.grid_weight }
    end
    
    it "should be ordered by grid_weight" do
      # Make sure it's got them
      @weights.length.should be == 10
      @value = 0
      @weights.each do |w|
        w.should be >= @value
        @value = w
      end
    end
    
    describe "deals scope" do
      before { @deals = Promotion.deals }
      
      it "should all be deals" do
        @deals.count.should == Promotion.count
      end
    end
    
    describe "deals scope (-1)" do
      before do
        @promotion = Promotion.first
        @promotion.update_attributes(:promotion_type => Promotion::AD, :destination => "Valid Ad")
      end
      
      it "should eliminate a deal" do
        Promotion.deals.count.should == Promotion.count - 1
      end
    end
    
    describe "ads scope" do
      before { @ads = Promotion.ads }
      
      it "should not have ads" do
        @ads.count.should == 0
      end
    end
    
    describe "ads scope (+1)" do
      before do
        @promotion = Promotion.first
        @promotion.update_attributes(:promotion_type => Promotion::AD, :destination => "Valid Ad")
      end
      
      describe "should have ads" do
        before { @ads = Promotion.ads }
        
        it "should have an ad" do
          @ads.count.should == 1
        end
      end
    end
    
    describe "affiliates scope" do
      before { @affiliates = Promotion.affiliates }
      
      it "should not have affiliates" do
        @affiliates.count.should == 0
      end
    end
    
    describe "affiliates scope (+1)" do
      before do
        @promotion = Promotion.first
        @promotion.update_attributes(:promotion_type => Promotion::AFFILIATE, :destination => "Valid Affiliate")
      end
      
      describe "should have affiliates" do
        before { @affiliates = Promotion.affiliates }
        
        it "should have an affiliates" do
          @affiliates.count.should == 1
        end
      end
    end
  end  
  
  describe "categories" do
    let(:promotion) { FactoryGirl.create(:promotion_with_categories) }
    
    it "should have categories" do
      promotion.categories.count.should be == 5
      promotion.categories.each do |cat| 
        cat.promotions.count.should == 1
      end
    end
    
    it "should not allow duplicate assignments" do
      expect { promotion.categories << promotion.categories[0] }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    
    describe "should still have categories after destroy" do
      before { promotion.destroy }
      
      it "categories should exist but not have any promotions" do
        Category.count.should be == 5
        Category.all.each do |cat|
          cat.promotions.count.should == 0
        end
      end
    end
  end
  
  describe "blog posts" do
    let(:promotion) { FactoryGirl.create(:promotion_with_blog_posts) }
    
    it "should have blog posts" do
      promotion.blog_posts.count.should be == 5
      promotion.blog_posts.each do |post| 
        post.promotions.count.should == 1
      end
    end
    
    it "should not allow duplicate assignments" do
      expect { promotion.blog_posts << promotion.blog_posts[0] }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    
    describe "should still have blog posts after destroy" do
      before { promotion.destroy }
      
      it "blog posts should exist but not have any promotions" do
        BlogPost.count.should be == 5
        BlogPost.all.each do |post|
          post.promotions.count.should == 0
        end
      end
    end
  end
  
  describe "promotion logs" do
    let(:promotion) { FactoryGirl.create(:promotion_with_logs) }
    
    it "should have logs" do
      promotion.promotion_logs.count.should be == 5
      promotion.promotion_logs.each do |log| 
        log.promotion.should == promotion
      end
    end
    
    describe "should destroy" do
      before { promotion.destroy }
      
      it "promotion logs should be gone" do
        PromotionLog.count.should == 0
      end
    end
  end  

  describe "promotion images" do
    let(:promotion) { FactoryGirl.create(:promotion_with_images) }
    
    it "should have images" do
      promotion.promotion_images.count.should be == 3
      promotion.promotion_images.each do |image| 
        image.promotion.should == promotion
      end
    end

    describe "should destroy" do
      before { promotion.reload.destroy }
      
      it "promotion images should be gone" do
        PromotionImage.count.should == 0
      end
    end
  end  
 
  describe "curators" do
    let(:curator) { FactoryGirl.create(:curator) }
    let(:blog_post1) { FactoryGirl.create(:blog_post, :curator => curator) }
    let(:blog_post2) { FactoryGirl.create(:blog_post) }    
    let(:blog_post3) { FactoryGirl.create(:blog_post, :curator => curator) }    
    
    describe "single curator" do
      before { blog_post1.promotions << promotion }
    
      it "should have one" do
        promotion.curators.should == [curator]
      end
    end
    
    describe "both curators" do
      before do
        blog_post1.promotions << promotion
        blog_post2.promotions << promotion
      end

      it "should have two" do
        promotion.curators.count.should be == 2
        promotion.curators.sort.should == [curator, blog_post2.curator].sort
      end
    end

    describe "one curator, two posts" do
      before do
        blog_post1.promotions << promotion
        blog_post3.promotions << promotion
      end

      it "should have unique curator" do
        promotion.curators.count.should be == 1
        promotion.curators.should == [curator]
      end
    end
  end

  describe "feedback" do
    let(:promotion) { FactoryGirl.create(:promotion_with_feedback) }
    
    it "should have feedback" do
      promotion.feedbacks.count.should be == 5
      promotion.orders.each do |order|
        promotion.feedbacks.include?(order.feedback).should be_true
        order.user.feedbacks.include?(order.feedback).should be_true
      end
    end
  end
  
  describe "subtitle" do
    let(:promotion) { FactoryGirl.create(:promotion_with_subtitle) }
    
    it "should have a subtitle" do
      promotion.subtitle.should_not be_blank
    end
  end
end
