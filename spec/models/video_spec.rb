# == Schema Information
#
# Table name: videos
#
#  id              :integer         not null, primary key
#  destination_url :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  title           :string(50)
#  curator_id      :integer
#  caption         :text
#  slug            :string(255)
#

describe "Videos" do
  let(:curator) { FactoryGirl.create(:curator) }
  let(:video) { FactoryGirl.create(:video, :curator => curator) }
  
  subject { video }
  
  it { should respond_to(:title) }
  it { should respond_to(:caption) }
  it { should respond_to(:destination_url) }
  its(:curator) { should == curator }
  
  it { should be_valid }
  
  describe "orphan" do
    before { video.curator = nil }
    
    it { should_not be_valid }
  end
  
  describe "title" do
    before { video.title = " " }
    
    it { should_not be_valid }
  end
  
  describe "caption" do
    before { video.caption = " " }
    
    it { should_not be_valid }
  end
  
  describe "destination" do
    before { video.destination_url = " " }
    
    it { should_not be_valid }
  end 
  
  describe "default scope" do
    before do
      video.destroy
      @videos = []
    
      3.times do
        sleep 2
        @videos.push(FactoryGirl.create(:video, :curator => curator) )
      end
    end
    
    it "should put them in order" do
      Video.all.should == @videos.reverse
    end
  end 
end
