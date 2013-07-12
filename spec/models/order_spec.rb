# == Schema Information
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  description    :string(255)
#  email          :string(255)
#  amount         :decimal(, )
#  promotion_id   :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fine_print     :text
#  quantity       :integer          default(1), not null
#  slug           :string(255)
#  name           :string(73)
#  address_1      :string(50)
#  address_2      :string(50)
#  city           :string(50)
#  state          :string(2)
#  zipcode        :string(10)
#  transaction_id :string(15)
#  first_name     :string(24)
#  last_name      :string(48)
#  pickup_notes   :string(255)
#

describe "Orders" do
  let(:user) { FactoryGirl.create(:user) }
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  
  subject { order }

  it "should respond to everything" do
    order.should respond_to(:amount)
    order.should respond_to(:description)
    order.should respond_to(:email)
    order.should respond_to(:quantity)
    order.should respond_to(:fine_print)
    order.should respond_to(:promotion)
    order.should respond_to(:user)
    order.should respond_to(:vendor)
    order.should respond_to(:macho_buck)
    order.should respond_to(:vouchers)
    order.should respond_to(:total_cost)
    order.should respond_to(:feedback)
    order.should respond_to(:machovy_share)
    order.should respond_to(:merchant_share)
    order.should respond_to(:first_name)
    order.should respond_to(:last_name)
    order.should respond_to(:name)
    order.should respond_to(:address_1)
    order.should respond_to(:address_2)
    order.should respond_to(:city)
    order.should respond_to(:state)
    order.should respond_to(:zipcode)
    order.should respond_to(:shipping_address)
    order.should respond_to(:transaction_id)
    order.should respond_to(:pickup_notes)
    order.should respond_to(:product_order?)
    order.should respond_to(:shipping_address_required?)
    order.user.should be == user
    order.promotion.should be == promotion
    order.vendor.should be == promotion.vendor
  end
  
  it { should be_valid }
  
  describe "First name too long" do
    before { order.first_name = "a"*(User::MAX_FIRST_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Last name too long" do
    before { order.last_name = "a"*(User::MAX_LAST_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "with name" do
    before do
      order.first_name = 'Jeffrey'
      order.last_name = 'Bennett'
    end
    
    it { should be_valid }
  end
  
  describe "long transaction id" do
#    before { order.transaction_id = "8"*(ActiveMerchant::Billing::MachovySecureNetGateway::TRANSACTION_ID_LEN + 1) }
    before { order.transaction_id = "8"*(15 + 1) }
    
    it { should_not be_valid }
  end
  
  describe "invalid transaction id" do
    ['abc', "-1", "2.5", "", " ", nil].each do |id|
      before { order.transaction_id = id }  
      
      it { should_not be_valid }
    end
  end
  
  describe "Macho Bucks transaction id" do
    before { order.transaction_id = Order::MACHO_BUCKS_TRANSACTION_ID }
    
    it { should be_valid }
  end

  describe "pickup orders" do
    let(:promotion) { FactoryGirl.create(:product_pickup_promotion) }
    let(:order) { FactoryGirl.create(:order_with_name, :user => user, :promotion => promotion) }    

    it "should not have a shipping address" do
      order.shipping_address_required?.should be_false
      order.product_order?.should be_true
      order.shipping_address.should match("^For pickup")
    end
    
    describe "Missing name" do
      before { order.name = ' ' }
      
      it { should_not be_valid }      
    end
    
    describe "Missing notes" do
      before { order.pickup_notes = ' ' }
      
      it { should be_valid }
    end
  end
  
  describe "delivery orders" do
    let(:promotion) { FactoryGirl.create(:product_promotion) }
    let(:order) { FactoryGirl.create(:order_with_address, :user => user, :promotion => promotion) }
    
    it "should have a shipping address" do
      order.shipping_address_required?.should be_true
      order.product_order?.should be_true
      order.shipping_address.should match("^Ship to")
    end
    
    describe "missing part of address" do
      before { order.address_1 = " " }
      
      it { should_not be_valid }
    end

    describe "missing city" do
      before { order.city = " " }
      
      it { should_not be_valid }
    end

    describe "missing name" do
      before { order.name = " " }
      
      it { should_not be_valid }
    end

    describe "missing state" do
      before { order.state = " " }
      
      it { should_not be_valid }
    end

    describe "invalid state" do
      before { order.state = "AP" }
      
      it { should_not be_valid }
    end

    describe "lowercase state" do
      before { order.state = "pa" }
      
      it { should be_valid }
    end

    describe "missing zipcode" do
      before { order.zipcode = " " }
      
      it { should_not be_valid }
    end
  end
  
  describe "macho bucks" do
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_order, :order => order) }
    before { macho_buck }
    
    it "should point to the bucks" do
      order.macho_buck.should == macho_buck
    end
  end
  
  describe "missing email" do
    before { order.email = " " }
    
    it { should_not be_valid }
    
    describe "email format (valid)" do
      ApplicationHelper::VALID_EMAILS.each do |address|
        before { order.email = address }
        
        it { should be_valid }
      end
    end

    describe "email format (invalid)" do
      ApplicationHelper::INVALID_EMAILS.each do |address|
        before { order.email = address }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "missing amount" do
    before { order.amount = nil }
    
    it { should_not be_valid }
    
    describe "non-numeric amount" do
      before { order.amount = "sdfs" }
      
      it { should_not be_valid }
    end

    describe "negative amount" do
      before { order.amount = -2.5 }
      
      it { should_not be_valid }
    end
  end
  
  describe "missing quantity" do
    before { order.quantity = nil }
    
    it { should_not be_valid }
  end
  
  describe "invalid quantities" do
    [" ", 0, 1.5, -2].each do |q|
      before { order.quantity = q }
      
      it { should_not be_valid }
    end
  end
  
  describe "cost calculation" do
    before do
      order.quantity = 5
      order.amount = 0.2
    end
    
    it "should calculate correctly" do
      order.total_cost.should be == 1.0
      # pennies
      order.total_cost(true).should be == 100.0
      order.machovy_share.should be == promotion.revenue_shared / 100.0
      order.merchant_share.should == (100.0 - promotion.revenue_shared) / 100.0
    end
  end
  
  it "should have default quantity" do
    order.quantity.should == 1
  end
  
  describe "vouchers" do
    let(:order) { FactoryGirl.create(:order_with_vouchers) }
    
    it { should be_valid }

    it "should have vouchers" do
      order.vouchers.count.should be == 3
      order.vouchers.each do |v|
        v.order.should be == order
        v.user.should == order.user
      end
    end
    
    describe "deleting the order deletes the vouchers" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with vouchers" do
        order.vouchers.count.should == 3
      end
      
      it "should destroy associated vouchers" do
        vouchers = order.vouchers
        order.destroy
        vouchers.each do |v|
          Voucher.find_by_id(v.id).should be_nil
        end
      end     
    end
    
    describe "orders should validate vouchers" do
      it "should have vouchers" do
        order.vouchers.count.should == 3
      end
      
      describe "invalidate a voucher" do
        before { order.reload.vouchers[0].update_attributes(:expiration_date => " ") }
        
        it { should_not be_valid }
      end
    end
  end

  describe "Feedback" do
    let(:user) { FactoryGirl.create(:user_with_feedback) }
    
    it "should have orders" do
      user.orders.count.should == 3
    end
    
    it "should have feedback" do
      user.orders.each do |order|
        order.feedback.should_not be_nil
        user.feedbacks.include?(order.feedback).should be_true
      end
    end
  end
end
