# == Schema Information
#
# Table name: careers
#
#  id            :integer         not null, primary key
#  title         :string(255)
#  description   :text
#  expiration    :datetime
#  email_contact :string(255)
#  email_subject :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

describe "Careers" do
  let(:career) { FactoryGirl.create(:career) }
  
  subject { career }
  
  it { should respond_to(:description) }
  it { should respond_to(:email_contact) }
  it { should respond_to(:email_subject) }
  it { should respond_to(:expiration) }
  it { should respond_to(:title) }
  
  it { should be_valid }
  
  describe "missing description" do
    before { career.description = " " }
    
    it { should_not be_valid }
  end
  
  describe "missing email contact" do
    before { career.email_contact = " " }
    
    it { should_not be_valid }
    
    describe "email format (valid)" do
      ApplicationHelper::VALID_EMAILS.each do |address|
        before { career.email_contact = address }
        
        it { should be_valid }
      end
    end

    describe "email format (invalid)" do
      ApplicationHelper::INVALID_EMAILS.each do |address|
        before { career.email_contact = address }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "missing email subject" do
    before { career.email_subject = " " }
    
    it { should_not be_valid }
  end
  
  describe "no expiration" do
    before { career.expiration = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing title" do
    before { career.title = " " }
    
    it { should_not be_valid }
  end
end

