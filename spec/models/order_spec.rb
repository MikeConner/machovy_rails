# == Schema Information
#
# Table name: orders
#
#  id                :integer         not null, primary key
#  description       :string(255)
#  email             :string(255)
#  amount            :decimal(, )
#  stripe_card_token :string(255)
#  promotion_id      :integer
#  user_id           :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  fine_print        :text
#

describe "Orders" do
  let (:user) { FactoryGirl.create(:user) }
  let (:promotion) { FactoryGirl.create(:promotion) }
  let (:order) { FactoryGirl.create(:order, :user => user, :promotion => promotion) }
  
  subject { order }
  
  it { should respond_to(:amount) }
  it { should respond_to(:description) }
  it { should respond_to(:email) }
  it { should respond_to(:stripe_card_token) }
  it { should respond_to(:fine_print) }
  
  it { should respond_to(:promotion) }
  it { should respond_to(:user) }
  it { should respond_to(:vendor) }
  it { should respond_to(:vouchers) }
  
  its(:user) { should == user }
  its(:promotion) { should == promotion }
  its(:vendor) { should == promotion.vendor }
  
  it { should be_valid }
  
  describe "missing email" do
    before { order.email = " " }
    
    it { should_not be_valid }
    
    describe "email format (valid)" do
      ApplicationHelper::VALID_EMAILS.each do |address|
        before { order.email = address }
        
        it { should be_valid }
      end
    end

    describe "email format (invalid)" do
      ApplicationHelper::INVALID_EMAILS.each do |address|
        before { order.email = address }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "missing amount" do
    before { order.amount = nil }
    
    it { should_not be_valid }
    
    describe "non-numeric amount" do
      before { order.amount = "sdfs" }
      
      it { should_not be_valid }
    end

    describe "negative amount" do
      before { order.amount = -2.5 }
      
      it { should_not be_valid }
    end
  end
  
  describe "missing stripe card" do
    before { order.stripe_card_token = " " }
    
    it { should_not be_valid }
  end
  
  describe "vouchers" do
    let(:order) { FactoryGirl.create(:order_with_vouchers) }
    
    it { should respond_to(:amount) }
    it { should respond_to(:description) }
    it { should respond_to(:email) }
    it { should respond_to(:stripe_card_token) }
    it { should respond_to(:fine_print) }
    
    it { should respond_to(:promotion) }
    it { should respond_to(:user) }
    it { should respond_to(:vendor) }
    it { should respond_to(:vouchers) }
        
    it { should be_valid }

    it "should have vouchers" do
      order.vouchers.count.should == 3
      order.vouchers.each do |v|
        v.order.should == order
        v.user.should == order.user
      end
    end
    
    describe "deleting the order deletes the vouchers" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with vouchers" do
        order.vouchers.count.should == 3
      end
      
      it "should destroy associated vouchers" do
        vouchers = order.vouchers
        order.destroy
        vouchers.each do |v|
          Voucher.find_by_id(v.id).should be_nil
        end
      end     
    end
    
    describe "orders should validate vouchers" do
      it "should have vouchers" do
        order.vouchers.count.should == 3
      end
      
      describe "invalidate a voucher" do
        before { order.reload.vouchers[0].update_attributes(:expiration_date => " ") }
        
        it { should_not be_valid }
      end
    end
  end
end
