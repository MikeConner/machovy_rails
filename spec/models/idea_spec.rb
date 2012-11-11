# == Schema Information
#
# Table name: ideas
#
#  id         :integer         not null, primary key
#  name       :string(16)
#  title      :string(40)
#  content    :text
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe "Idea" do
  let(:user) { FactoryGirl.create(:user) }
  let(:idea) { FactoryGirl.create(:idea, :user => user) }
  
  subject { idea }
  
  it { should respond_to(:name) }
  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:ratings) }
  it { should respond_to(:average_rating) }
  it { should respond_to(:num_comments) }
  it { should respond_to(:<=>) }
  
  its(:user) { should == user }
  
  it { should be_valid }
  
  describe "no name" do
    before { idea.name = " " }
    
    it { should_not be_valid }
  end

  describe "no title" do
    before { idea.title = " " }
    
    it { should_not be_valid }
  end

  describe "no content" do
    before { idea.content = " " }
    
    it { should_not be_valid }
  end

  describe "orphan" do
    before { idea.user = nil }
    
    it { should_not be_valid }
  end

  describe "ratings" do
    let(:idea) { FactoryGirl.create(:idea_with_ratings) }
    
    it "should have ratings" do
      idea.ratings.count.should be == 5
      idea.num_comments.should be == 0
      idea.ratings.each do |rating|
        rating.idea.should == idea
      end
    end
    
    it "should not allow duplicates" do
      expect { idea.reload.ratings << idea.reload.ratings.first.dup }.to raise_exception(ActiveRecord::RecordNotUnique)
    end
    
    describe "should delete on destroy" do
      before { idea.reload.destroy }
      
      it "should not have ratings" do
        Rating.count.should == 0
      end
    end
    
    describe "ordering" do
      it "should compute the average" do
        sum = 0.0
        idea.ratings.each do |rating|
          sum += rating.stars
        end
        
        idea.average_rating.should == sum / idea.ratings.count
      end
      
      describe "sort them properly" do
        before do
          @idea2 = FactoryGirl.create(:idea_with_ratings)
          @idea3 = FactoryGirl.create(:idea)
          @idea4 = FactoryGirl.create(:idea)
          @list = [idea, @idea2, @idea3, @idea4].sort
        end
        
        it "should put the highest one first" do
         @list[0].average_rating.should >= @list[1].average_rating 
        end
        
        it "if no ratings, comment count should be 0" do
          @idea3.num_comments.should == 0
        end
        
        it "should put the two unrated ones last" do
          @list[2].average_rating.should be_nil
          @list[3].average_rating.should be_nil
        end
        
        describe "rating with no comment" do
          before { idea.ratings << FactoryGirl.create(:rating_with_comment, :idea => idea) }
          
          it "should have 6" do
            idea.ratings.count.should be == 6
            idea.num_comments.should == 1
          end
        end
      end
    end
  end
end
