# == Schema Information
#
# Table name: relative_expiration_strategies
#
#  id          :integer         not null, primary key
#  period_days :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

describe "RelativeExpirationStrategy" do
  let(:strategy) { FactoryGirl.create(:relative_expiration_strategy) }
  
  subject { strategy }
  
  it { should respond_to(:period_days) }
  it { should respond_to(:promotion) }
  
  it { should be_valid }
  
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
end
