# == Schema Information
#
# Table name: ratings
#
#  id         :integer         not null, primary key
#  stars      :integer
#  comment    :text
#  idea_id    :integer
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe "Rating" do
  let(:user) { FactoryGirl.create(:user) }
  let(:rating_user) { FactoryGirl.create(:user) }
  let(:idea) { FactoryGirl.create(:idea, :user => user) }
  let(:rating) { FactoryGirl.create(:rating, :user => rating_user, :idea => idea) }
  
  subject { rating }
  
  it "should respond to everything" do
    rating.should respond_to(:stars)
    rating.should respond_to(:comment)
    rating.idea.should be == idea
    rating.user.should be == rating_user
  end
   
  describe "default rating" do
    before { @new_rating = Rating.new }
    
    it "should be set to default on new" do
      @new_rating.stars.should == Rating::DEFAULT_RATING
    end
    
    describe "default should not override disk" do
      before do
        @disk_rating = FactoryGirl.create(:rating, :stars => 2)
      end
      
      it "should be 2" do 
        @disk_rating.reload.stars.should == 2
      end
    end
  end
  
  describe "stars (valid)" do
    for stars in 1..5 do
      before { rating.stars = stars }
      
      it { should be_valid }
    end
  end
  
  describe "stars (invalid)" do
    [nil, '', ' ', 0, 0.5, 6, 10, "abc"].each do |stars|
      before { rating.stars = stars }
      
      it { should_not be_valid }
    end
  end
  
  it "cannot rate own idea" do
    expect { FactoryGirl.create(:rating, :user => user, :idea => idea) }.to raise_exception(ActiveRecord::RecordInvalid)
  end
end
