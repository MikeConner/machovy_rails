describe "Categories" do
  let(:category) { FactoryGirl.create(:category) }
  
  subject { category }
  
  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:promotions) }
  
  it { should be_valid }
  
  describe "name validation" do
    before { category.name = " " }
    
    it { should_not be_valid }
  end
  
  describe "duplicate names" do
    before { @category2 = category.dup }
    
    it "shouldn't allow exact duplicates" do
      @category2.should_not be_valid
    end
    
    describe "case sensitivity" do
      before do
        @category2 = category.dup
        @category2.name = category.name.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @category2.should_not be_valid
      end
    end
  end
  
  describe "status" do
    before { category.status = nil }
    
    it { should_not be_valid }
  end
  
  describe "false status" do
    let(:category) { FactoryGirl.create(:inactive_category) }
    
    it { should be_valid }
    
    it "should be inactive" do
      category.status.should be_false
    end
  end
end
