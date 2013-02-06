# == Schema Information
#
# Table name: product_strategies
#
#  id         :integer         not null, primary key
#  delivery   :boolean         default(TRUE)
#  sku        :string(48)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'promotion_strategy_factory'

describe "ProductStrategy" do
  let(:promotion) { FactoryGirl.create(:product_promotion_with_order) }
  let(:order) { Order.last }
  
  subject { promotion }
  
  it "should respond to everything" do
    promotion.strategy.should respond_to(:delivery)
    promotion.strategy.should respond_to(:sku)
    promotion.strategy.should respond_to(:promotion)
    promotion.strategy.should respond_to(:name)
    promotion.strategy.should respond_to(:setup)
    promotion.strategy.should respond_to(:generate_vouchers)
  end
  
  it { should be_valid }
  
  it "should have a valid strategy" do
    promotion.strategy.should be_valid
  end
  
  it "should have the right name" do
    promotion.strategy.name.should == PromotionStrategyFactory::PRODUCT_STRATEGY
  end
  
  it "should have a promotion with flags set" do
    promotion.strategy.delivery?.should be_true
    order.shipping_address_required?.should be_true
    order.shipping_address.should match("^Ship to")
  end
  
  describe "Pickup strategy" do
    let(:promotion) { FactoryGirl.create(:product_pickup_promotion_with_order) }
    
    it { should be_valid }
    
    it "should have the flags set correctly" do
      promotion.strategy.should be_valid
      promotion.strategy.delivery?.should be_false
      order.shipping_address_required?.should be_false
      order.shipping_address.should =~ /^For pickup/
    end
  end
  
  describe "setup" do
    before do
      params = Hash.new
      params['delivery'] = '1'
      params['sku'] = ' 11blah '
      
      promotion.strategy.setup(params)
    end
    
    it "should have the correct fields set" do
      promotion.strategy.delivery?.should be_true
      promotion.strategy.sku.should be == "11blah"
    end
  end
  
  describe "voucher generation" do
    before do
      promotion.strategy.generate_vouchers(order)
      @voucher = Voucher.first
    end
    
    it "should create a voucher" do
      Voucher.count.should be == 1
      order.vouchers.count.should be == 1
      order.vouchers.first.should be == @voucher
      @voucher.notes.should match(order.fine_print)
      @voucher.notes.should match(order.shipping_address)
      @voucher.valid_date.should be == DateTime.now.beginning_of_day
      @voucher.redemption_date.should be == DateTime.now.beginning_of_day
      @voucher.status.should be == Voucher::REDEEMED
      @voucher.expiration_date.should be == 1.year.from_now.beginning_of_day
      @voucher.order.should be == order
      @voucher.promotion.should be == order.promotion
      order.total_cost.should == promotion.price.round(2)
    end
  end  
end
