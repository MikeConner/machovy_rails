describe "Coupon" do
  let(:vendor) { FactoryGirl.create(:vendor) }
  let(:coupon) { FactoryGirl.create(:coupon, :vendor => vendor) }
  
  subject { coupon }
  
  it "should respond to everything" do
    coupon.should respond_to(:title)
    coupon.should respond_to(:value)
    coupon.should respond_to(:description)
    coupon.should respond_to(:coupon_image)
  end
  
  its(:vendor) { should be == vendor }
  it { should be_valid }
  
  describe "orphan" do
    before { coupon.vendor_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "No title" do
    before { coupon.title = ' ' }
    
    it { should_not be_valid }    
  end
  
  describe "Title too long" do
    before { coupon.title = 't'*(Coupon::MAX_TITLE_LEN + 1) }
    
    it { should_not be_valid }    
  end
  
  describe "No value" do
    before { coupon.value = nil }
    
    it { should be_valid }
  end
  
  describe "Invalid values" do
    [-1, 0, 2.5, 'abc'].each do |value|
      before { coupon.value = value }
      
      it { should_not be_valid }
    end
  end
  
  describe "Coupon without image" do
    before { coupon.remove_coupon_image! }
    
    it { should_not be_valid }
  end
end
