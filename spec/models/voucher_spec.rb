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
#  payment_id      :integer
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
  it { should respond_to(:redeemable?) }
  it { should respond_to(:returnable?) }
  it { should respond_to(:paid?) }
  it { should respond_to(:payment_owed?) }
  it { should respond_to(:payment) }
  
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
    
    it { should_not be_valid }
    
    it "is valid because it creates one" do
      voucher.reload.uuid.should_not be_blank
    end
  end
  
  describe "status (valid)" do
    Voucher::VOUCHER_STATUS.each do |status|
      before { voucher.status = status }
      
      it { should be_valid }
      # consistency -- they can both be false, but can't both be true
      it "should be consistent" do
        if voucher.redeemable? || voucher.payment_owed?
          (voucher.redeemable?^voucher.payment_owed?).should be_true
        end
        
        if [Voucher::AVAILABLE, Voucher::EXPIRED].include?(voucher.status)
          voucher.redeemable?.should be_true
        end
        
        if Voucher::REDEEMED == voucher.status
          voucher.payment_owed?.should be_true
        end
        
        if Voucher::AVAILABLE == voucher.status
          voucher.returnable?.should be_true
        end
      end
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

  describe "payments" do
    let(:payment) { FactoryGirl.create(:payment, :vendor => voucher.promotion.vendor) }

    it "should not be paid" do
      voucher.paid?.should be_false
      voucher.payment_owed?.should be_false
    end
    
    it "should not allow payment_id assignment" do
      expect { voucher.update_attributes(:payment_id => payment.id) }.to raise_exception(ActiveModel::MassAssignmentSecurity::Error) 
    end
    
    describe "should show owed when redeemed" do
      before { voucher.status = Voucher::REDEEMED }
      
      it "should show owed" do
        voucher.payment_owed?.should be_true
      end
    end
    describe "should show paid when assigned" do
      before do
       voucher.payment_id = payment.id
       voucher.save! 
      end
      
      it "should be paid now" do
        voucher.payment.should be == payment
        voucher.paid?.should be_true
      end
    end
  end
end
