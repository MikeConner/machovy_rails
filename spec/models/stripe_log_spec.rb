# == Schema Information
#
# Table name: stripe_logs
#
#  id         :integer         not null, primary key
#  event_id   :string(40)
#  event_type :string(40)
#  livemode   :boolean
#  event      :text
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe "StripeLog" do
  let(:user) { FactoryGirl.create(:user) }
  let(:log) { FactoryGirl.create(:stripe_log, :user => user) }
  
  subject { log }
  
  it { should respond_to(:event_id) }
  it { should respond_to(:event_type) }
  it { should respond_to(:livemode) }
  it { should respond_to(:event) }
  its(:user) { should == user }
  
  it { should be_valid }
    
  describe "missing event id" do
    before { log.event_id = " " }
    
    it { should_not be_valid }
  end

  describe "event id too long" do
    before { log.event_id = "a"*(StripeLog::MAX_STR_LEN + 1) }
    
    it { should_not be_valid }
  end

  describe "valid event types" do
    StripeLog::EVENT_TYPES.each do |type|
      before { log.event_type = type }
      
      it { should be_valid }
    end
  end
  
  describe "invalid event type" do
    before { log.event_type = "not in the list" }
    
    it { should_not be_valid }
  end
  
  it "ensure monitored types are included in the master list" do
    StripeLog::MONITORED_TYPES.each do |type|
      StripeLog::EVENT_TYPES.include?(type).should be_true
    end
  end

  describe "missing status" do
    before { log.livemode = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing event" do
    before { log.event = " " }
    
    it { should_not be_valid }
  end

  describe "should have test one" do
    before { log }
    
    it "should be 1" do
      StripeLog.test.count.should be == 1
      StripeLog.test.first.should == log
    end
  end
  
  describe "scopes" do
    before { @live = FactoryGirl.create(:live_stripe_log) }
        
    it "should have live one" do
      StripeLog.live.count.should be == 1
      StripeLog.live.first.should == @live
    end
  end
end
