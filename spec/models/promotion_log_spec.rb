# == Schema Information
#
# Table name: promotion_logs
#
#  id           :integer         not null, primary key
#  promotion_id :integer
#  status       :string(32)      not null
#  comment      :text
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

describe "PromotionLog" do
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:log) { FactoryGirl.create(:promotion_log, :promotion => promotion) }
  
  subject { log }
  
  it { should respond_to(:status) }
  it { should respond_to(:comment ) }
  it { should respond_to(:promotion) }
  
  its(:promotion) { should == promotion }
  
  it { should be_valid }
  
  describe "missing status" do
    before { log.status = " " }
    
    it { should_not be_valid }
  end
  
  describe "invalid status" do
    before { log.status = "NOT IN LIST" }
    
    it { should_not be_valid }
  end
  
  describe "status too long" do
    before { log.status = "a"*(Promotion::MAX_STR_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "blank comment" do
    before { log.comment = " " }
    
    it { should be_valid }
  end
  
  describe "missing comment" do
    before { log.comment = nil }
    
    it { should be_valid }
  end
  
  describe "orphan" do
    before { log.promotion_id = nil }
    
    it { should_not be_valid }
  end
end
