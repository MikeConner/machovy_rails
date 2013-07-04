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
#  exclusive          :boolean         default(FALSE)
#

describe "Categories" do
  let(:category) { FactoryGirl.create(:category) }
  let(:for_her) { FactoryGirl.create(:exclusive_category) }
  let(:metro) { FactoryGirl.create(:metro) }
  subject { category }
  
  it "should respond to everything" do
    category.should respond_to(:name)
    category.should respond_to(:active)
    category.should respond_to(:parent_category_id)
    category.should respond_to(:sub_categories)
    category.should respond_to(:promotions)
    category.should respond_to(:exclusive)
    category.parent_category.should be_nil
  end
  
  it { should be_valid }
  
  it "should default to non-exclusive" do
    category.exclusive.should be_false
  end
  
  it "should define the scope" do
    category.exclusive.should be_false
    for_her.exclusive.should be_true
    Category.count.should be == 2
    Category.non_exclusive.should be == [category]
    Category.exclusive.should be == [for_her]
    Category.roots.should be == [category, for_her]
    Category.active.should be == [category, for_her]
  end
  
  describe "Filtering" do
    before do
      @third = FactoryGirl.create(:category)
      @p1 = FactoryGirl.create(:promotion, :metro => metro, :status => Promotion::MACHOVY_APPROVED)
      @p2 = FactoryGirl.create(:promotion, :metro => metro, :status => Promotion::MACHOVY_APPROVED)
      @p3 = FactoryGirl.create(:promotion, :metro => metro, :status => Promotion::MACHOVY_APPROVED)
      @p1.categories << category
      @p2.categories << for_her
      @p3.categories << @third
    end
    
    it "should filter the promotions correctly" do
      find_selection(Category::ALL_ITEMS_ID).should be_nil
      (filter_deals(nil, metro.name) & [@p1, @p3]).count.should be == 2
      filter_deals(category.name, metro.name).should be == [@p1]
      filter_deals(for_her.name, metro.name).should be == [@p2]
      filter_deals(@third.name, metro.name).should be == [@p3]
    end
  end
  
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
      Category.active.should be_empty
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

def find_selection(category)
  # "All" will not be found, so will set selected_category to nil, equivalent to no category
  category.nil? ? nil : Category.find(:first, :conditions => [ "lower(name) = ?", category.downcase ]) 
end

def filter_deals(category, metro)   
  selected_category = find_selection(category)
  
  if selected_category.nil?
    non_exclusive = Category.non_exclusive.map { |c| c.id }
    Promotion.all.select { |p| p.displayable? and (p.metro.name == metro) and !(p.category_ids & non_exclusive).empty? }.sort
  else
    Promotion.all.select { |p| p.displayable? and (p.metro.name == metro) and p.category_ids.include?(selected_category.id) }.sort
  end
end

