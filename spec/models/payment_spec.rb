# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  amount       :decimal(, )      not null
#  check_number :integer          not null
#  check_date   :date             not null
#  notes        :text
#  vendor_id    :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

describe "Payments" do
  let(:vendor) { FactoryGirl.create(:vendor) }
  let(:payment) { FactoryGirl.create(:payment, :vendor => vendor) }
  
  subject { payment }
  
  it "should respond to everything" do
    payment.should respond_to(:amount)
    payment.should respond_to(:check_number)
    payment.should respond_to(:check_date)
    payment.should respond_to(:notes)
    payment.vendor.should be == vendor
  end
  
  it { should be_valid }
  
  describe "amount" do
    [nil, " ", "", -2, 0].each do |amount|
      before { payment.amount = amount }
    
      it { should_not be_valid }
    end
  end
  
  describe "check number (invalid)" do
    [nil, " ", "", 0, 1.5, Payment::MINIMUM_CHECK_NUMBER - 1].each do |number|
      before { payment.check_number = number }
      
      it { should_not be_valid }
    end
  end

  describe "check number (valid)" do
    before { payment.check_number = Payment::MINIMUM_CHECK_NUMBER }
      
    it { should be_valid }
  end
  
  describe "check date" do
    before { payment.check_date = " " }
    
    it { should_not be_valid }
  end
  
  describe "orphan" do
    before { payment.vendor_id = nil }
    
    it { should_not be_valid }
  end
  
  it "should not have notes" do
    payment.notes.should be_nil
  end
  
  describe "notes" do
    let(:payment) { FactoryGirl.create(:payment_with_notes) }
    
    it { should be_valid }
    it "should have notes" do
      payment.notes.should_not be_nil
    end
  end
end
