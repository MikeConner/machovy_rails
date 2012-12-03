# == Schema Information
#
# Table name: fixed_expiration_strategies
#
#  id         :integer         not null, primary key
#  end_date   :datetime        not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe "FixedExpirationStrategy" do
  let(:strategy) { FactoryGirl.create(:fixed_expiration_strategy) }
  
  subject { strategy }
  
  it { should respond_to(:end_date) }
  it { should respond_to(:promotion) }
  it { should respond_to(:setup) }
  it { should respond_to(:generate_vouchers) }
  
  it { should be_valid }
  
  it "should have a promotion" do
    strategy.promotion.should_not be_nil
    strategy.promotion.strategy.should == strategy
  end
  
  describe "missing time" do
    before { strategy.end_date = nil }
    
    it { should_not be_valid }
  end
  
  describe "setup" do
    before do
      params = Hash.new
      params[:promotion] = Hash.new
      params[:promotion]['end_date(1i)'] = '2012'
      params[:promotion]['end_date(2i)'] = '11'
      params[:promotion]['end_date(3i)'] = '30'
      
      strategy.setup(params)
    end
    
    it "should have the correct date" do
      strategy.end_date.should == DateTime.parse('2012-11-30')
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
      @voucher.valid_date.should be == DateTime.now.beginning_of_day
      @voucher.status.should be == Voucher::AVAILABLE
      @voucher.expiration_date.should be == strategy.end_date
      @voucher.order.should be == order
      @voucher.promotion.should be == order.promotion
      order.total_cost.should == promotion.price
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
      order.total_cost.should be == promotion.price * 3
      @vouchers.each do |voucher|
        order.vouchers.include?(voucher).should be_true
        voucher.notes.should be == order.fine_print
        voucher.valid_date.should be == DateTime.now.beginning_of_day
        voucher.status.should be == Voucher::AVAILABLE
        voucher.expiration_date.should be == strategy.end_date
        voucher.order.should be == order
        voucher.promotion.should be == order.promotion
      end
    end
  end
end
