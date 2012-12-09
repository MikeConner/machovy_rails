# == Schema Information
#
# Table name: macho_bucks
#
#  id         :integer         not null, primary key
#  amount     :decimal(, )     not null
#  notes      :text
#  admin_id   :integer
#  user_id    :integer
#  voucher_id :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  order_id   :integer
#

describe "MachoBucks" do
  let(:user) { FactoryGirl.create(:user) }
  let(:macho_buck) { FactoryGirl.create(:macho_buck, :user => user) }
  
  subject { macho_buck }
  
  it "should respond to everything" do
    macho_buck.should respond_to(:amount)
    macho_buck.should respond_to(:notes)
    macho_buck.should respond_to(:voucher)
    macho_buck.should respond_to(:order)
    macho_buck.should respond_to(:admin)
    macho_buck.user.should == user
  end
  
  it { should be_valid }
  
  describe "no user" do
    before { macho_buck.user_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "valid amount" do
    [-10, -5, 0, 2.5, 300.32].each do |amount|
      before { macho_buck.amount = amount }
      
      it { should be_valid }
    end
  end

  describe "invalid amount" do
    [nil, 'abc'].each do |amount|
      before { macho_buck.amount = amount }
      
      it { should_not be_valid }
    end
  end
  
  describe "voucher bucks" do
    let(:voucher) { FactoryGirl.create(:voucher) }
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_voucher, :voucher => voucher) }
    
    its(:voucher) { should == voucher }
  end
  
  describe "order bucks" do
    let(:order) { FactoryGirl.create(:order) }
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_order, :order => order) }
    
    its(:order) { should == order }
  end
  
  describe "admin adjusted bucks" do
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_admin) }
    
    it { should be_valid }
    
    it "should have an admin" do
      macho_buck.user.should_not be_nil
      macho_buck.user.has_role?(Role::SUPER_ADMIN).should be_false
      macho_buck.admin.should_not be_nil
      macho_buck.admin.should_not be == macho_buck.user
      macho_buck.admin.has_role?(Role::SUPER_ADMIN).should be_true
      macho_buck.voucher.should be_nil
    end
  end
  
  describe "non-admin adjusted bucks" do
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_nonadmin) }
    
    it { should_not be_valid }
  end
end
