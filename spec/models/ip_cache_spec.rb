# == Schema Information
#
# Table name: ip_caches
#
#  id         :integer          not null, primary key
#  ip         :string(16)       not null
#  latitude   :decimal(, )      not null
#  longitude  :decimal(, )      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

describe IpCache do
  let(:ip) { FactoryGirl.create(:ip_cache) }
  
  subject { ip }
  
  it "should respond to everything" do
    ip.should respond_to(:ip)
    ip.should respond_to(:latitude)
    ip.should respond_to(:longitude)
  end
  
  it { should be_valid }
  
  describe "Missing ip" do
    before { ip.ip = '' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid ip" do 
    before { ip.ip = '32.432.3243' }
    
    it { should_not be_valid }
  end
  
  describe "Missing latitude" do
    before { ip.latitude = '' }
    
    it { should_not be_valid }
  end
  
  describe "Missing longitude" do
    before { ip.longitude = '' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid latitude" do
    before { ip.latitude = 'abc' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid longitude" do
    before { ip.longitude = 'abc' }
    
    it { should_not be_valid }
  end  
end
