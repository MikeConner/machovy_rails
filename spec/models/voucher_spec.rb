# == Schema Information
#
# Table name: vouchers
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  redemption_date :datetime
#  status          :string(16)      default("Available")
#  notes           :text
#  expiration_date :datetime
#  issue_date      :datetime
#  order_id        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
#

describe "Vouchers" do
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:user) { FactoryGirl.create(:user) }
  let(:order) { FactoryGirl.create(:order, :promotion => promotion, :user => user) }
  let(:voucher) { FactoryGirl.create(:voucher, :order => order) }
  
  subject { voucher }
  
  it { should respond_to(:expiration_date) }
  it { should respond_to(:issue_date) }
  it { should respond_to(:notes) }
  it { should respond_to(:status) }
  it { should respond_to(:uuid) }
  it { should respond_to(:user) }
  it { should respond_to(:order) }
  it { should respond_to(:promotion) }
  it { should respond_to(:expiration_date) }
  it { should respond_to(:issue_date) }
  it { should respond_to(:redemption_date) }
  it { should respond_to(:expired?) }
  it { should respond_to(:open?) }
  
  its(:order) { should == order }
  its(:user) { should == user }
  its(:promotion) { should == promotion }
  
  it { should be_valid }
  
  describe "expiration date" do
    before { voucher.expiration_date = " " }
    
    it { should_not be_valid }
  end

  describe "issue date" do
    before { voucher.issue_date = " " }
    
    it { should_not be_valid }
  end

  describe "status" do
    before { voucher.status = " " }
    
    it { should_not be_valid }
  end

  describe "uuid" do
    before { voucher.uuid = " " }
    
    it { should be_valid }
    it "is valid because it creates one" do
      voucher.reload.uuid.should_not be_blank
    end
  end
  
  describe "status (valid)" do
    Voucher::VOUCHER_STATUS.each do |status|
      before { voucher.status = status }
      
      it { should be_valid }
    end 
  end
  
  describe "status (invalid)" do
    ['Invalid', 'asdf', '', nil].each do |status|
      before { voucher.status = status }
      
      it { should_not be_valid }
    end 
  end
  
  describe "time periods" do
    it "should be open" do
      voucher.open?.should be_true
    end
    
    describe "expired before issued" do
      before { voucher.expiration_date = voucher.issue_date - 1.day }
      
      it { should_not be_valid }
      it "should not be open" do
        voucher.open?.should be_false
      end
    end
    
    it "should not be expired" do
      voucher.expired?.should be_false
    end
    
    describe "expired" do
      before { voucher.expiration_date = 1.day.ago }
      
      it "should be expired" do
        voucher.expired?.should be_true
      end
    end
  end
end
