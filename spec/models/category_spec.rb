# == Schema Information
#
# Table name: categories
#
#  id                 :integer         not null, primary key
#  name               :string(255)     not null
#  active             :boolean
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  parent_category_id :integer
#

describe "Categories" do
  let(:category) { FactoryGirl.create(:category) }
  
  subject { category }
  
  it { should respond_to(:name) }
  it { should respond_to(:active) }
  it { should respond_to(:parent_category_id) }
  it { should respond_to(:sub_categories) }
  it { should respond_to(:promotions) }
  
  its(:parent_category) { should be_nil }
  
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
    before { category.active = nil }
    
    it { should_not be_valid }
  end
  
  describe "inactive status" do
    let(:category) { FactoryGirl.create(:inactive_category) }
    
    it { should be_valid }
    
    it "should be inactive" do
      category.active.should be_false
    end
  end

  describe "promotions" do
    let(:category) { FactoryGirl.create(:category_with_promotions) }
    
    it "should have promotions" do
      category.promotions.count.should be == 5
      category.promotions.each do |p| 
        p.categories.include?(category).should be_true
      end
    end
    
    it "should not allow duplicate assignments" do
      expect { category.promotions << category.promotions[0] }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    
    it "should not have sub-categories" do
      category.sub_categories.count.should == 0
    end
    
    describe "should still have promotions after destroy" do
      before { category.destroy }
      
      it "promotions should exist but not have any posts" do
        Promotion.count.should be == 5
        Promotion.all.each do |p|
          p.categories.count.should == 0
        end
      end
    end
  end
  
  describe "Hierarchical categories" do
    let(:category) { FactoryGirl.create(:hierarchical_category) }
    
    it "should have sub-categories" do
      category.sub_categories.count.should be == 3
      Category.unscoped.all.count.should be == 4
      
      category.sub_categories.each do |sub| 
        sub.parent_category.should == category
      end
    end
    
    describe "destroying the parent should destroy sub-categories" do
      before { category.destroy }
      
      it "should be completely empty" do
        Category.unscoped.reload.count.should == 0
      end
    end  
  end  
end
