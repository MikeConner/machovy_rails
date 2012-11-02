# == Schema Information
#
# Table name: videos
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  destination_url :string(255)
#  active          :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

describe "Videos" do
  let(:video) { FactoryGirl.create(:video) }
  
  subject { video }
  
  it { should respond_to(:active) }
  it { should respond_to(:destination_url) }
  it { should respond_to(:active) }
  
  it { should be_valid }
  
  describe "name" do
    before { video.name = " " }
    
    it { should_not be_valid }
  end
  
  describe "destination" do
    before { video.destination_url = " " }
    
    it { should_not be_valid }
  end
  
  describe "active missing" do
    before { video.active = nil }
    
    it { should_not be_valid }
  end
  
  describe "inactive" do
    let(:video) { FactoryGirl.create(:inactive_video) }
    
    it { should respond_to(:active) }
    it { should respond_to(:destination_url) }
    it { should respond_to(:active) }
    
    it { should be_valid }
  
    it "should be inactive" do
      video.active.should be_false
    end
  end
end
