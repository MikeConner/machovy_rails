# == Schema Information
#
# Table name: promotions
#
#  id                   :integer         not null, primary key
#  title                :string(255)
#  description          :text            default(""), not null
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
#  destination          :string(255)     default(""), not null
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  slug                 :string(255)
#  status               :string(32)      default("Proposed")
#

describe "Promotions" do
  let (:metro) { FactoryGirl.create(:metro) }
  let (:vendor) { FactoryGirl.create(:vendor) }
  let (:promotion) { FactoryGirl.create(:promotion, :metro => metro, :vendor => vendor) }
  
  subject { promotion }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:destination) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:grid_weight) }
  it { should respond_to(:limitations) }
  it { should respond_to(:quantity) }
  it { should respond_to(:retail_value) }
  it { should respond_to(:revenue_shared) }
  it { should respond_to(:teaser_image) }
  it { should respond_to(:voucher_instructions) }
  it { should respond_to(:main_image) }
  it { should respond_to(:remote_main_image_url) }
  it { should respond_to(:remote_teaser_image_url) }
  it { should respond_to(:orders) }
  it { should respond_to(:vouchers) }
  it { should respond_to(:categories) }
  it { should respond_to(:blog_posts) }
  
  its(:metro) { should == metro }
  its(:vendor) { should == vendor }
  
  it { should be_valid}

  describe "retail value (valid)" do
    [0, 2.5, 18].each do |v|
      before { promotion.retail_value = v }
      
      it { should be_valid }
    end
  end
  
  describe "retail value (invalid)" do   
    [-1, -1.25, 'abc'].each do |v|
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
    [-1, -1.25, 'abc'].each do |p|
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
    [-1, -1.25, 'abc'].each do |r|
      before { promotion.revenue_shared = r }
      
      it { should_not be_valid }
    end
  end
  
  describe "quantity (valid)" do
    [0, 1, 5, 180].each do |q|
      before { promotion.quantity = q }
      
      it { should be_valid }
    end
  end
  
  describe "quantity (invalid)" do  
    [1.5, -2, -1.25, 'abc'].each do |q|
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
    [0, 1.5, -2, -1.25, 'abc'].each do |w|
      before { promotion.grid_weight = w }
      
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
    let (:promotion) { FactoryGirl.create(:promotion_with_orders, :metro => metro, :vendor => vendor) }
    
    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:destination) }
    it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:grid_weight) }
    it { should respond_to(:limitations) }
    it { should respond_to(:quantity) }
    it { should respond_to(:retail_value) }
    it { should respond_to(:revenue_shared) }
    it { should respond_to(:teaser_image) }
    it { should respond_to(:voucher_instructions) }
    it { should respond_to(:main_image) }
    it { should respond_to(:remote_main_image_url) }
    it { should respond_to(:remote_teaser_image_url) }
    it { should respond_to(:orders) }
    it { should respond_to(:vouchers) }
    it { should respond_to(:categories) }
    it { should respond_to(:blog_posts) }
    
    its(:metro) { should == metro }
    its(:vendor) { should == vendor }
    
    it { should be_valid}

    it "should have orders" do
      promotion.orders.count.should == 5
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
  
  it "should not be an ad" do
    promotion.ad?.should be_false
  end
  
  it "should not be an affiliate" do
    promotion.affiliate?.should be_false
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
  
  describe "make it an ad" do
    before { promotion.description = " " }
    
    it "should be an ad" do
      promotion.ad?.should be_true
    end
  end
  
  describe "make it an affiliate" do
    before { promotion.destination = "something" }
    
    it "should be an affiliate" do
      promotion.affiliate?.should be_true
    end
  end  
  
  describe "make it approved" do
    before { promotion.status = Promotion::MACHOVY_APPROVED }
    
    it "should be approved" do
      promotion.approved?.should be_true
    end
    
    it "should be displayable" do
      promotion.displayable?.should be_true
    end
    
    describe "Approved but not displayable" do
      before { promotion.end_date = 1.week.ago }
      
      it "should be approved" do
        promotion.approved?.should be_true
      end
      
      it "should not be displayable" do
        promotion.displayable?.should be_false
      end
    end      
  end
  
  describe "test remaining vouchers" do
    let (:promotion) { FactoryGirl.create(:promotion_with_vouchers) }    
    before { promotion.quantity = 20 }

    it "should have quantity - vouchers" do
      promotion.vouchers.count.should == 15
      promotion.quantity.should == 20
      promotion.remaining_quantity.should == 5
    end
    
    describe "all used" do
      before { promotion.quantity = 20 }
      
      it "should have none left" do
        promotion.reload.remaining_quantity.should == 0
      end
    end
    
    describe "can't be negative (invalid quantity)" do
      before { promotion.quantity = 10 }
      
      it "should say zero instead of negative" do
        promotion.reload.remaining_quantity.should == 0
      end
    end
    
    describe "can't be negative (nil)" do
      before { promotion.quantity = nil }
      
      it "should say zero when nil" do
        promotion.reload.remaining_quantity.should == 0
      end
    end
  end
  
  describe "scopes" do
    before do
      Promotion.destroy_all
      @promotions = FactoryGirl.create_list(:promotion, 10)
      @weights = Promotion.all.map { |n| n.grid_weight }
    end
    
    it "should be ordered by grid_weight" do
      @value = 0
      @weights.each do |w|
        w.should >= @value
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
        @promotion.update_attributes(:description => "")
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
        @promotion.update_attributes(:description => "")
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
        @promotion.update_attributes(:destination => "amazon.com")
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
      promotion.categories.count.should == 5
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
        Category.count.should == 5
        Category.all.each do |cat|
          cat.promotions.count.should == 0
        end
      end
    end
  end
  
  describe "blog posts" do
    let(:promotion) { FactoryGirl.create(:promotion_with_blog_posts) }
    
    it "should have blog posts" do
      promotion.blog_posts.count.should == 5
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
        BlogPost.count.should == 5
        BlogPost.all.each do |post|
          post.promotions.count.should == 0
        end
      end
    end
  end
end
