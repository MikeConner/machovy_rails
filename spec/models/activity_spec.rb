# == Schema Information
#
# Table name: activities
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  activity_name :string(32)      not null
#  activity_id   :integer         not null
#  description   :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

describe "Activity" do
  let(:user) { FactoryGirl.create(:user) }
  let(:activity) { FactoryGirl.create(:activity, :user => user) }
  
  subject { activity }
  
  it "should respond to everything" do
    activity.should respond_to(:user_id)
    activity.should respond_to(:activity_id)
    activity.should respond_to(:activity_name)
    activity.should respond_to(:description)
    activity.should respond_to(:init_activity)
    activity.should respond_to(:duration)
    activity.user.should == user
  end
  
  it { should be_valid }
  
  describe "No user" do
    before { activity.user_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "No activity id" do
    before { activity.activity_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "No activity name" do
    before { activity.activity_name = " " }
    
    it { should_not be_valid }
  end
  
  describe "Name too long" do
    before { activity.activity_name = "n"*(Activity::MAX_NAME + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Duration" do
    before do
      # Let doesn't create the object until it's used, so need to touch before sleeping to create it!
      activity.touch
      sleep 3
      activity.touch
    end
    
    it "should show the right duration" do
      activity.reload.duration.should >= 3
    end
  end
  
  describe "init activity" do
    let(:promotion) { FactoryGirl.create(:promotion) }
    before { activity.init_activity(promotion) }
    
    it "should match the class" do
      activity.activity_name.should == promotion.class.name
    end

    it "should match the id" do
      activity.activity_id.should == promotion.id
    end
    
    it "shouldn't fail on invalid activity" do
      expect { activity.init_activity(nil) }.to_not raise_exception
    end
  end
end
