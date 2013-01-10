# == Schema Information
#
# Table name: gift_certificates
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  amount         :integer         not null
#  email          :string(255)     not null
#  pending        :boolean         default(TRUE)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  transaction_id :string(15)
#  first_name     :string(24)
#  last_name      :string(48)
#

describe "GiftCertificate" do
  let(:super_user) { FactoryGirl.create(:super_admin_user) }
  let(:content_user) { FactoryGirl.create(:content_admin_user) }
  let(:merchant_user) { FactoryGirl.create(:merchant_user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:certificate) { FactoryGirl.create(:gift_certificate, :user => user) }
  let(:redeemed_certificate) { FactoryGirl.create(:redeemed_gift_certificate, :user => user) }
  before do
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::CONTENT_ADMIN)
    Role.create(:name => Role::SALES_ADMIN)
    Role.create(:name => Role::MERCHANT)    
  end
  
  subject { certificate }
  
  it "should respond to everything" do
    certificate.should respond_to(:user)
    certificate.should respond_to(:amount)
    certificate.should respond_to(:transaction_id)
    certificate.should respond_to(:email)
    certificate.should respond_to(:first_name)
    certificate.should respond_to(:last_name)
    certificate.should respond_to(:pending)
  end
  
  it { should be_valid }
  
  its(:user) { should == user }

  describe "First name too long" do
    before { certificate.first_name = "a"*(User::MAX_FIRST_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "Last name too long" do
    before { certificate.last_name = "a"*(User::MAX_LAST_NAME_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "with name" do
    before do
      certificate.first_name = 'Jeffrey'
      certificate.last_name = 'Bennett'
    end
    
    it { should be_valid }
  end
  
  
  describe "valid amount" do
    [1, 10, 500].each do |amount|
      before { certificate.amount = amount }
      
      it { should be_valid }
    end
  end

  describe "invalid amount" do
    [0, -10, "", " ", nil, "abc"].each do |amount|
      before { certificate.amount = amount }
      
      it { should_not be_valid }
    end
  end
  
  describe "orphan" do
    before { certificate.user_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "Invalid email" do
    [nil, " ", "blah@com"].each do |email|
      before { certificate.email = email }
    
      it { should_not be_valid }
    end
  end
  
  describe "long transaction id" do
#    before { order.transaction_id = "8"*(ActiveMerchant::Billing::MachovySecureNetGateway::TRANSACTION_ID_LEN + 1) }
    before { certificate.transaction_id = "8"*(15 + 1) }
    
    it { should_not be_valid }
  end
  
  describe "invalid transaction id" do
    ['abc', "-1", "2.5", "", " ", nil].each do |id|
      before { certificate.transaction_id = id }  
      
      it { should_not be_valid }
    end
  end

  describe "Missing pending flag" do
    before { certificate.pending = nil }
    
    it { should_not be_valid }
  end
  
  describe "Prevent self-gifting" do
    before { certificate.email = "#{user.email.upcase}  " }
    
    it { should_not be_valid }
  end

  describe "Prevent gifting to admins" do
    before { certificate.email = super_user.email }
    
    it { should_not be_valid }
  end

  describe "Prevent gifting to merchants" do
    before { certificate.email = merchant_user.email }
    
    it { should_not be_valid }
  end

  describe "Prevent gifting to content admins" do
    before { certificate.email = content_user.email }
    
    it { should_not be_valid }
  end
  
  describe "Scopes" do
    it "should have two" do
      certificate.pending.should be_true
      redeemed_certificate.pending.should be_false
      GiftCertificate.count.should be == 2
    end
    
    it "should only have one pending" do
      GiftCertificate.pending.should be == [certificate]
      redeemed_certificate.pending.should be_false      
      GiftCertificate.redeemed.should be == [redeemed_certificate]
      GiftCertificate.all.should be == [certificate, redeemed_certificate]
    end
  end
end
