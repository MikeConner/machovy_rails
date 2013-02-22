# == Schema Information
#
# Table name: relative_expiration_strategies
#
#  id          :integer         not null, primary key
#  period_days :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  delay_hours :integer         default(0), not null
#

require 'promotion_strategy_factory'

describe "RelativeExpirationStrategy" do
  let(:strategy) { FactoryGirl.create(:relative_expiration_strategy) }
  
  subject { strategy }
  
  it "should respond to everything" do
    strategy.should respond_to(:period_days)
    strategy.should respond_to(:promotion)
    strategy.should respond_to(:name)
    strategy.should respond_to(:setup)
    strategy.should respond_to(:generate_vouchers)
  end
  
  it { should be_valid }
  
  describe "delay" do
    let(:strategy) { FactoryGirl.create(:fixed_expiration_strategy_with_delay) }
    
    it "should have a delay" do
      strategy.delay_hours.should be == 6
    end
    
    describe "zero is ok" do
      before { strategy.delay_hours = 0 }
      
      it { should be_valid }
    end
    
    describe "Invalid delay" do
      [-2, 1.5, 'abc'].each do |delay|
        before { strategy.delay_hours = delay }
        
        it { should_not be_valid }
      end
    end
  end
    
  it "should have the right name" do
    strategy.name.should == PromotionStrategyFactory::RELATIVE_STRATEGY
  end

  it "should not have a delay" do
    strategy.delay_hours.should be == 0
  end
    
  it "should have a promotion" do
    strategy.promotion.should_not be_nil
    strategy.promotion.strategy.should == strategy
  end
  
  describe "invalid period" do
    [0, -1, 0.5, 'abc', nil].each do |period|
      before { strategy.period_days = period }
    
      it { should_not be_valid }
    end
  end
  
  describe "setup" do
    before do
      params = Hash.new
      params[:period] = '60'
      
      strategy.setup(params)
    end
    
    it "should have the correct date" do
      strategy.period_days.should == 60
    end
  end
  
  describe "voucher generation" do
    let(:promotion) { FactoryGirl.create(:promotion) }
    let(:order) { FactoryGirl.create(:order, :amount => promotion.price, :promotion => promotion) }
    before do
      strategy.generate_vouchers(order)
      @voucher = Voucher.first
    end
    
    it "should create a voucher" do
      Voucher.count.should be == 1
      order.vouchers.count.should be == 1
      order.vouchers.first.should be == @voucher
      @voucher.notes.should be == order.fine_print
      @voucher.valid_date.should be == Time.zone.now.beginning_of_day
      @voucher.status.should be == Voucher::AVAILABLE
      @voucher.expiration_date.should be == strategy.period_days.days.from_now.beginning_of_day
      @voucher.order.should be == order
      @voucher.promotion.should be == order.promotion
      order.total_cost.should == promotion.price.round(2)
    end
  end

  describe "multiple voucher generation" do
    let(:promotion) { FactoryGirl.create(:promotion) }
    let(:order) { FactoryGirl.create(:order, :amount => promotion.price, :promotion => promotion, :quantity => 3) }
    before do
      strategy.generate_vouchers(order)
      @vouchers = Voucher.all
    end
    
    it "should create a voucher" do
      Voucher.count.should be == 3
      order.vouchers.count.should be == 3
      order.total_cost.should be == (promotion.price * 3).round(2)
      @vouchers.each do |voucher|
        order.vouchers.include?(voucher).should be_true
        voucher.notes.should be == order.fine_print
        voucher.valid_date.should be == Time.zone.now.beginning_of_day
        voucher.status.should be == Voucher::AVAILABLE
        voucher.expiration_date.should be == strategy.period_days.days.from_now.beginning_of_day
        voucher.order.should be == order
        voucher.promotion.should be == order.promotion
      end
    end
  end  
end
