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
  
  it { should be_valid }
  
  it "should have a promotion" do
    strategy.promotion.should_not be_nil
    strategy.promotion.strategy.should == strategy
  end
  
  describe "missing time" do
    before { strategy.end_date = nil }
    
    it { should_not be_valid }
  end
end
