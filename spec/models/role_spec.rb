# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

describe "Roles" do
  let(:role) { FactoryGirl.create(:role) }
  
  subject { role }
  
  it { should respond_to(:name) }
  it { should respond_to(:users) }
  
  it { should be_valid }
  
  describe "duplicate names" do
    before { @role2 = role.dup }
    
    it "shouldn't allow exact duplicates" do
      @role2.should_not be_valid
    end
    
    describe "case sensitivity" do
      before do
        @role2 = role.dup
        @role2.name = role.name.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @role2.should_not be_valid
      end
    end
  end

  describe "promotions" do
    let(:role) { FactoryGirl.create(:role_with_users) }
    
    it "should have users" do
      role.users.count.should be == 5
      role.users.each do |u| 
        u.roles.include?(role).should be_true
      end
    end
    
    it "should not allow duplicate assignments" do
      expect { role.users << role.users[0] }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    
    describe "should still have users after destroy" do
      before { role.destroy }
      
      it "users should exist but not have any roles" do
        User.count.should be == 5
        User.all.each do |u|
          u.roles.count.should == 0
        end
      end
    end
  end  
end
