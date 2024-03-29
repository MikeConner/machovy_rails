# == Schema Information
#
# Table name: feedbacks
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  order_id   :integer
#  stars      :integer
#  recommend  :boolean
#  comments   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

describe "Feedback" do
  let(:user) { FactoryGirl.create(:user) }
  let(:order) { FactoryGirl.create(:order, :user => user) }
  let(:feedback) { FactoryGirl.create(:feedback, :user => user, :order => order) }
  
  subject { feedback }
  
  it "should respond to everything" do
    feedback.should respond_to(:comments)
    feedback.should respond_to(:recommend)
    feedback.should respond_to(:stars)
    feedback.user.should be == user
    feedback.order.should == order
  end
  
  it { should be_valid }
  
  describe "missing user" do
    before { feedback.user = nil }
    
    it { should_not be_valid }
  end

  describe "missing order" do
    before { feedback.order = nil }
    
    it { should_not be_valid }
  end

  describe "missing recommend" do
    before { feedback.recommend = nil }
    
    it { should_not be_valid }
  end

  describe "valid stars" do
    for s in 1..5 do 
      before { feedback.stars = s }
      
      it { should be_valid }      
    end
  end

  describe "invalid stars" do
    [0, -1, 1.5, nil, "", "blah"].each do |s| 
      before { feedback.stars = s }
      
      it { should_not be_valid }      
    end
  end
end
