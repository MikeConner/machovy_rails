describe "Metros" do
  let(:metro) { FactoryGirl.create(:metro) }
  
  subject { metro }
  
  it { should respond_to(:name) }
  it { should respond_to(:promotions) }
  
  it { should be_valid }
  
  describe "name validation" do
    before { metro.name = nil }
    
    it { should_not be_valid }
  
    describe "blank name" do
      before { metro.name = " " }
      
      it { should_not be_valid }
    end
  end
    
  describe "duplicate name" do
    before { @metro2 = metro.dup }
    
    it "shouldn't allow exact duplicates" do
      @metro2.should_not be_valid
    end
    
    describe "case insensitive" do
      before { @metro2.name = metro.name.upcase }
      
      it "shouldn't allow case variant duplicates" do
        @metro2.should_not be_valid
      end
    end
  end
  
  describe "promotions" do
    let(:metro) { FactoryGirl.create(:metro_with_promotions) }
        
    it { should respond_to(:name) }
    it { should respond_to(:promotions) }
    
    it { should be_valid }
    
    it "should have promotions" do
      metro.promotions.count.should == 4
      metro.promotions.each do |p|
        p.metro.should == promoted_metro
      end
    end
    
    describe "deleting the metro doesn't delete promotions" do
      before do
        @id = metro.id
        metro.destroy
      end
      
      it "should still have promotions" do
        Promotion.all.count.should == 4
        # They have stale references, though; this should never happen; just testing dependencies
        Promotion.find_by_metro_id(@id).should_not be_nil
      end
    end
  end
end
