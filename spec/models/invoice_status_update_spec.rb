# == Schema Information
#
# Table name: invoice_status_updates
#
#  id                 :integer         not null, primary key
#  bitcoin_invoice_id :integer
#  status             :string(15)      default("new")
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

describe InvoiceStatusUpdate do
  let(:invoice) { FactoryGirl.create(:bitcoin_invoice) }
  let(:update) { FactoryGirl.create(:invoice_status_update, :bitcoin_invoice => invoice) }
  
  subject { update }
  
  it "should respond to everything" do
    update.status.should_not be_nil
  end
  
  its(:bitcoin_invoice) { should be == invoice }
  
  it { should be_valid }
end
