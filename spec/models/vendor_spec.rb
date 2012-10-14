# == Schema Information
#
# Table name: vendors
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  url        :string(255)
#  facebook   :string(255)
#  phone      :string(255)
#  address_1  :string(255)
#  address_2  :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer
#

describe "Vendors" do
  let (:user) { FactoryGirl.create(:user) }
  let (:vendor) { FactoryGirl.create(:vendor, :user => user) }
  
  subject { vendor }

  it { should respond_to(:address_1) }
  it { should respond_to(:address_2) }
  it { should respond_to(:city) }
  it { should respond_to(:facebook) }
  it { should respond_to(:name) }
  it { should respond_to(:phone) }
  it { should respond_to(:state) }
  it { should respond_to(:url) }
  it { should respond_to(:zip) }
  it { should respond_to(:promotions) }
  it { should respond_to(:metros) }
  it { should respond_to(:orders) }
  
  its(:user) { should == user }
  
  it { should be_valid }

  describe "name" do
    before { vendor.name = " " }
    
    it { should_not be_valid }
  end
  
  describe "address" do
    before { vendor.address_1 = " " }
    
    it { should_not be_valid }
  end
  
  describe "city" do
    before { vendor.city = "  "}
    
    it { should_not be_valid }
  end
  
  describe "state" do 
    before { vendor.state = " " }
    
    it { should_not be_valid }
    
    describe "validate against list" do
      ApplicationHelper::US_STATES.each do |state|
        before { vendor.state = state }
        
        it { should be_valid }
      end
      
      describe "invalid state" do
        before { vendor.state = "Not a state" }
        
        it { should_not be_valid }
      end
    end
  end

  describe "no zip code" do
    before { vendor.zip = nil }
    
    it { should_not be_valid }
  end
  
  describe "zip code (valid)" do
    ["13416", "15237", "15237-2339"].each do |code|
      before { vendor.zip = code }
      
      it { should be_valid }
    end
  end

  describe "zip code (invalid)" do  
    ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
      before { vendor.zip = code }
     
      it { should_not be_valid }
    end
  end  

  describe "phone (valid)" do
    ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
      before { vendor.phone = phone }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "phone (invalid)" do  
    ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
      before { vendor.phone = phone }
     
      it { should_not be_valid }
    end
  end  

  describe "missing phone" do
    before { vendor.phone = nil }
    
    it { should_not be_valid }
  end
  
  describe "url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { vendor.url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { vendor.url = url }
     
      it { should_not be_valid }
    end
  end  

  describe "facebook (valid)" do
    ["http://www.facebook.com/jeffrey.bennett.7737", "facebook.com/jeff.bennett.342", "www.facebook.com/jeffrey.bennett.3423"].each do |fb|
      before { vendor.facebook = fb }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "facebook (invalid)" do  
    ["xyz", "facebook", "https://www.facebook.com", "bookface.com/jeff.3423", "@jeff", "facebook/jeff"].each do |fb|
      before { vendor.facebook = fb }
     
      it { should_not be_valid }
    end
  end  

  describe "should allow deletion if no promotions" do
    it "should not have promotions" do
      vendor.promotions.count.should == 0
    end
    
    describe "delete" do
      before do
        @id = vendor.id
        vendor.destroy
      end
      
      it "should allow deletion" do
        expect { Vendor.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe "promotions" do
    let(:vendor) { FactoryGirl.create(:vendor_with_promotions, :user => user) }
    
    it { should respond_to(:address_1) }
    it { should respond_to(:address_2) }
    it { should respond_to(:city) }
    it { should respond_to(:facebook) }
    it { should respond_to(:name) }
    it { should respond_to(:phone) }
    it { should respond_to(:state) }
    it { should respond_to(:url) }
    it { should respond_to(:zip) }
    it { should respond_to(:promotions) }
    it { should respond_to(:metros) }
    it { should respond_to(:orders) }
    
    its(:user) { should == user }
    
    it "should have promotions" do
      vendor.promotions.count.should == 5
      vendor.promotions.each do |p|
        p.vendor.should == vendor
      end
    end
    
    it "should have metros" do
      vendor.metros.count.should > 0
    end

    it "should not have orders" do
      vendor.orders.count.should == 0
    end
    
    describe "deleting the vendor doesn't delete promotions" do
      before { @id = vendor.id }
      
      it "shouldn't allow deletion" do
        expect { vendor.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Vendor.find(@id).should == vendor
      end
      
      it "should still have promotions" do
        Promotion.unscoped.reload.count.should == 5
        Promotion.find_by_metro_id(@id).should_not be_nil
      end
    end    
  end
  
  describe "orders" do
    let(:vendor) { FactoryGirl.create(:vendor_with_orders, :user => user) }

    it { should respond_to(:address_1) }
    it { should respond_to(:address_2) }
    it { should respond_to(:city) }
    it { should respond_to(:facebook) }
    it { should respond_to(:name) }
    it { should respond_to(:phone) }
    it { should respond_to(:state) }
    it { should respond_to(:url) }
    it { should respond_to(:zip) }
    it { should respond_to(:promotions) }
    it { should respond_to(:metros) }
    it { should respond_to(:orders) }
    
    its(:user) { should == user }
    
    it "should have orders" do
      vendor.orders.count.should == 25
      vendor.orders.each do |order|
        order.vendor.should == vendor
      end
    end
    
    describe "validate promotions" do
      before { vendor.reload.promotions[0].update_attributes(:retail_value => -1) }
      
      it { should_not be_valid }
    end
        
    describe "deleting the vendor doesn't delete orders" do
      before { @id = vendor.id }
      
      it "shouldn't allow deletion" do
        expect { vendor.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Vendor.find(@id).should == vendor
      end
      
      it "should still have orders" do
        Order.unscoped.reload.count.should == 25
      end
    end 
    
    describe "deleting promotion doesn't delete orders" do
      before do
        @promotion = vendor.reload.promotions[0]
        @id = @promotion.id
      end
      
      it "shouldn't allow deletion" do
        expect { @promotion.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        Promotion.find(@id).should == @promotion
      end
      
      it "should still have promotions" do
        Promotion.unscoped.reload.count.should == 5
        Order.unscoped.reload.count.should == 25
      end
    end
     
    describe "deleting orders lets you delete promotions" do
      # Order.destroy_all does not work; don't ask me why
      before do
        vendor.reload.orders.each do |order|
          order.destroy
        end
      end
      
      it "should have promotions" do
        vendor.reload.promotions.count.should == 5
        vendor.reload.promotions.each do |p|
          p.vendor.should == vendor
        end
      end

      it "should not have orders" do
        vendor.reload.orders.count.should == 0
      end
      
      describe "deleting promotions lets you delete the vendor" do
        before { Promotion.destroy_all }
        
        it "should not have promotions" do
          vendor.reload.promotions.count.should == 0
          vendor.reload.orders.count.should == 0
        end
        
        describe "delete" do
          before do
            @id = vendor.id
            vendor.reload.destroy
          end
          
          it "should allow deletion" do
            expect { Vendor.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
          end
        end        
      end
    end   
  end
end
