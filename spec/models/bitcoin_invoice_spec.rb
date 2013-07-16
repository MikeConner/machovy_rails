# == Schema Information
#
# Table name: bitcoin_invoices
#
#  id               :integer         not null, primary key
#  order_id         :integer
#  price            :decimal(, )
#  currency         :string(3)       default("USD")
#  pos_data         :string(255)
#  notification_key :string(255)
#  invoice_id       :string(255)
#  invoice_url      :string(255)
#  btc_price        :decimal(, )
#  invoice_time     :datetime
#  expiration_time  :datetime
#  current_time     :datetime
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

describe BitcoinInvoice do
  let(:order) { FactoryGirl.create(:order) }
  let(:invoice) { FactoryGirl.create(:bitcoin_invoice, :order => order) }
  
  subject { invoice }
  
  it "should respond to everything" do
    invoice.should respond_to(:order_id)
    invoice.should respond_to(:price)
    invoice.should respond_to(:currency)
    invoice.should respond_to(:pos_data)
    invoice.should respond_to(:notification_key)
    invoice.should respond_to(:invoice_id)
    invoice.should respond_to(:invoice_url)
    invoice.should respond_to(:btc_price)
    invoice.should respond_to(:invoice_time)
    invoice.should respond_to(:expiration_time)
    invoice.should respond_to(:current_time)
    invoice.should respond_to(:invoice_status)
  end
  
  its(:order) { should be == order }
  
  it { should be_valid }
  
  it "should have new status" do
    invoice.invoice_status.should be == InvoiceStatusUpdate::NEW
  end
  
  describe "with status" do
    let(:invoice) { FactoryGirl.create(:invoice_with_status) }
    
    it "should have status" do
      invoice.invoice_status.should be == invoice.invoice_status_updates.first.status
    end
  end
  
  describe "Missing invoice id" do
    before { invoice.invoice_id = nil }
    
    it { should_not be_valid }
  end  
  
  describe "Missing current time" do
    before { invoice.current_time = nil }
    
    it { should_not be_valid }
  end

  describe "Missing expiration_time time" do
    before { invoice.expiration_time = nil }
    
    it { should_not be_valid }
  end

  describe "Missing invoice time" do
    before { invoice.invoice_time = nil }
    
    it { should_not be_valid }
  end

  describe "Missing notification key" do
    before { invoice.notification_key = nil }
    
    it { should_not be_valid }
  end

  describe "Missing invoice url" do
    before { invoice.invoice_url = nil }
    
    it { should_not be_valid }
  end
  
  describe "invalid url" do
    before { invoice.invoice_url = 'Not a url' }
    
    it { should_not be_valid }
  end
  
  describe "invalid price" do
    ['abc', nil].each do |price|
      before { invoice.price = price }
      
      it { should_not be_valid }
    end
  end

  describe "invalid btc price" do
    ['abc', nil].each do |price|
      before { invoice.btc_price = price }
      
      it { should_not be_valid }
    end
  end
  
  describe "invalid currency" do
    before { invoice.currency = '' }
    
    it { should_not be_valid }
  end
  
  describe "valid currencies" do
    BitcoinInvoice::CURRENCIES.each do |currency|
      before { invoice.currency = currency }
      
      it { should be_valid }
    end
  end
  
  describe "invalid currency" do 
    before { invoice.currency = 'FISH' }
    
    it { should_not be_valid }
  end
end
