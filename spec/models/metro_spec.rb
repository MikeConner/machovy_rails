# == Schema Information
#
# Table name: metros
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  latitude   :decimal(, )     default(40.438169), not null
#  longitude  :decimal(, )     default(-80.001875), not null
#

describe "Metros" do
  let(:metro) { FactoryGirl.create(:metro) }
  
  subject { metro }
  
  it "should respond to everything" do
    metro.should respond_to(:name)
    metro.should respond_to(:promotions)
    metro.should respond_to(:latitude)
    metro.should respond_to(:longitude)
  end
  
  it { should be_valid }
  
  describe "distance calculations" do
    let(:vegas) { FactoryGirl.create(:metro, :name => 'Las Vegas', :latitude => 36.097339, :longitude => -115.172915)}
    let(:denver) { [39.8498700902431, -104.6964801287] }
    let(:atlanta) { [33.6400552831252, -84.4500422598234] }
    
    before do
      metro
      vegas
    end
    
    it "should have two metros" do
      Metro.count.should be == 2
    end
    
    it "should show Denver closer to vegas" do
      distances = Hash.new
      Metro.all.each do |metro|
        distances[metro.name] = metro.distance_from(denver)
      end
      distances.sort_by{|k,v| v}.first[0].should be == 'Las Vegas'
    end
    
    it "should show Atlanta closer to vegas" do
      distances = Hash.new
      Metro.all.each do |metro|
        distances[metro.name] = metro.distance_from(atlanta)
      end
      distances.sort_by{|k,v| v}.first[0].should be == metro.name
    end
  end
  
  describe "Missing latitude" do
    before { metro.latitude = nil }
    
    it { should_not be_valid }
  end
  
  describe "Missing longitude" do
    before { metro.longitude = nil }
    
    it { should_not be_valid }
  end

  describe "Invalid latitude" do
    before { metro.latitude = 'abc' }
    
    it { should_not be_valid }
  end
  
  describe "Invalid longitude" do
    before { metro.longitude = 'abc' }
    
    it { should_not be_valid }
  end
  
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
