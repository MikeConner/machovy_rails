# == Schema Information
#
# Table name: metros
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe "Metros" do
  let(:metro) { FactoryGirl.create(:metro) }
  
  subject { metro }
  
  it "should respond to everything" do
    metro.should respond_to(:name)
    metro.should respond_to(:promotions)
  end
  
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
  
  describe "should allow deletion if no promotions" do
    it "should not have promotions" do
      metro.promotions.count.should == 0
    end
    
    describe "delete" do
      before do
        @id = metro.id
        metro.destroy
      end
      
      it "should allow deletion" do
        expect { Metro.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe "promotions" do
    let(:metro) { FactoryGirl.create(:metro_with_promotions) }
        
    it { should respond_to(:name) }
    it { should respond_to(:promotions) }
    
    it { should be_valid }
    
    it "should have promotions" do
      metro.promotions.count.should be == 4
      metro.promotions.each do |p|
        p.metro.should == metro
      end
    end
    
    describe "deleting the metro doesn't delete promotions" do
      before { @id = metro.id }
      
      it "shouldn't allow deletion" do
        expect { metro.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Metro.find(@id).should == metro
      end
      
      it "should still have promotions" do
        Promotion.all.count.should be == 4
        Promotion.find_by_metro_id(@id).should_not be_nil
      end
    end
  end
end
