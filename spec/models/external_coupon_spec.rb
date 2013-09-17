describe ExternalCoupon do
  let(:metro) { FactoryGirl.create(:metro) }
  let(:coupon) { FactoryGirl.create(:external_coupon, :metro => metro) }
  
  subject { coupon }
  
  it "should respond to everything" do
    coupon.should respond_to(:address_1)
    coupon.should respond_to(:address_2)
    coupon.should respond_to(:big_image_url)
    coupon.should respond_to(:category_id)
    coupon.should respond_to(:city)
    coupon.should respond_to(:deal_discount)
    coupon.should respond_to(:deal_id)
    coupon.should respond_to(:deal_info)
    coupon.should respond_to(:deal_price)
    coupon.should respond_to(:deal_savings)
    coupon.should respond_to(:deal_type_id)
    coupon.should respond_to(:deal_url)
    coupon.should respond_to(:disclaimer)
    coupon.should respond_to(:distance)
    coupon.should respond_to(:expiration_date)
    coupon.should respond_to(:logo_url)
    coupon.should respond_to(:name)
    coupon.should respond_to(:original_price)
    coupon.should respond_to(:phone)
    coupon.should respond_to(:post_date)
    coupon.should respond_to(:small_image_url)
    coupon.should respond_to(:source)
    coupon.should respond_to(:state)
    coupon.should respond_to(:store_url)
    coupon.should respond_to(:subcategory_id)
    coupon.should respond_to(:title)
    coupon.should respond_to(:user_id)
    coupon.should respond_to(:user_name)
    coupon.should respond_to(:zip)
    coupon.should respond_to(:expired?)
  end
  
  its(:metro) { should be == metro }
  
  it { should be_valid }
  
  it "should not be expired" do
    coupon.expired?.should be_false
  end
  
  describe "expired coupon" do
    let(:coupon) { FactoryGirl.create(:expired_coupon, :metro => metro) }
    
    it "should be expired" do
      coupon.expired?.should be_true
    end
  end
  
  describe "Missing title" do
    before { coupon.title = nil }
    
    it { should_not be_valid }
  end

  describe "Missing name" do
    before { coupon.name = nil }
    
    it { should_not be_valid }
  end

  describe "Missing expiration" do
    before { coupon.expiration_date = nil }
    
    it { should_not be_valid }
  end
  
  describe "deal id" do
    [0, 1.5, 'abc', nil].each do |id|
      before { coupon.deal_id = id }
      
      it { should_not be_valid }
    end
  end

  describe "user id" do
    [0, 1.5, 'abc'].each do |id|
      before { coupon.deal_id = id }
      
      it { should_not be_valid }
    end
  end

  describe "city too long" do
    before { coupon.city = 'c'*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
      
    it { should_not be_valid }
  end
  
  describe "state" do 
    before { coupon.state = " " }
    
    it { should be_valid }
    
    describe "validate against list" do
      ApplicationHelper::US_STATES.each do |state|
        before { coupon.state = state }
        
        it { should be_valid }
      end
      
      describe "invalid state" do
        before { coupon.state = "Not a state" }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "phone (valid)" do
    ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
      before { coupon.phone = phone }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "phone (invalid)" do  
    ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
      before { coupon.phone = phone }
     
      it { should_not be_valid }
    end
  end  
  
  describe "zip code (valid)" do
    ["13416", "15237", "15237-2339"].each do |code|
      before { coupon.zip = code }
      
      it { should be_valid }
    end
  end

  describe "zip code (invalid)" do  
    ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
      before { coupon.zip = code }
     
      it { should_not be_valid }
    end
  end  
  
  describe "deal url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { coupon.deal_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "deal url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { coupon.deal_url = url }
     
      it { should_not be_valid }
    end
  end  
  
  describe "store url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { coupon.store_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "store url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { coupon.store_url = url }
     
      it { should_not be_valid }
    end
  end  

  describe "logo url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { coupon.logo_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "logo url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { coupon.logo_url = url }
     
      it { should_not be_valid }
    end
  end  
  
  describe "small image url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { coupon.small_image_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "small image url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { coupon.small_image_url = url }
     
      it { should_not be_valid }
    end
  end  
  
  describe "big image url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { coupon.big_image_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "big image url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { coupon.big_image_url = url }
     
      it { should_not be_valid }
    end
  end  
  
  describe "original price" do
    [0, 1.5, 'abc'].each do |price|
      before { coupon.original_price = price }
      
      it { should_not be_valid }
    end
  end
  
  describe "deal price" do
    [-1, 'abc'].each do |price|
      before { coupon.deal_price = price }
      
      it { should_not be_valid }
    end
  end
  
  describe "deal savings" do
    [-1, 'abc'].each do |price|
      before { coupon.deal_savings = price }
      
      it { should_not be_valid }
    end
  end
  
  describe "deal discount" do
    [-1, 'abc'].each do |price|
      before { coupon.deal_discount = price }
      
      it { should_not be_valid }
    end
  end

  describe "deal type id" do
    [-1, 1.5, 'abc'].each do |id|
      before { coupon.deal_type_id = id }
      
      it { should_not be_valid }
    end
  end
  
  describe "category id" do
    [0, 1.5, 'abc'].each do |id|
      before { coupon.category_id = id }
      
      it { should_not be_valid }
    end
  end
  
  describe "subcategory id" do
    [0, 1.5, 'abc'].each do |id|
      before { coupon.subcategory_id = id }
      
      it { should_not be_valid }
    end
  end
  
  describe "distance" do
    [-1, 'abc'].each do |d|
      before { coupon.distance = d }
      
      it { should_not be_valid }
    end
  end
end
