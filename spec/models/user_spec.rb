# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  stripe_id              :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  first_name             :string(24)
#  last_name              :string(48)
#  address_1              :string(50)
#  address_2              :string(50)
#  city                   :string(50)
#  state                  :string(2)
#  zipcode                :string(5)
#  phone                  :string(14)
#  optin                  :boolean         default(FALSE), not null
#  total_macho_bucks      :decimal(, )     default(0.0)
#

describe "Users" do
  let(:user) { FactoryGirl.create(:user) }
  
  subject { user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_me) }

  it { should respond_to(:orders) }
  it { should respond_to(:vouchers) }
  it { should respond_to(:roles) }
  it { should respond_to(:vendor) }
  it { should respond_to(:is_customer?) }
  it { should respond_to(:stripe_id) }
  it { should respond_to(:stripe_customer_obj) }
  it { should respond_to(:log_activity) }
    
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:phone) }
  it { should respond_to(:address_1) }
  it { should respond_to(:address_2) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zipcode) }
  it { should respond_to(:optin) }
  it { should respond_to(:categories) }
  it { should respond_to(:stripe_logs) }
  it { should respond_to(:total_macho_bucks) }
  it { should respond_to(:update_total_macho_bucks) }
  
  it { should be_valid }
 
  describe "invalid macho bucks" do
    before { user.total_macho_bucks = 'abc' }
    
    it { should_not be_valid }
  end
  
  describe "many macho bucks" do
    before do
      @sum = 0.0
      10.times do
        buck = FactoryGirl.create(:macho_buck, :user => user)
        @sum += buck.amount
      end
    end
    
    it "should match the sum" do
      MachoBuck.count.should be == 10
      user.reload.total_macho_bucks.should == @sum
    end
  end
  
  describe "valid macho bucks" do
    let(:macho_buck) { FactoryGirl.create(:macho_buck, :user => user) }
    
    before do
      macho_buck
      @bucks = MachoBuck.first
    end
    
    it "should have bucks" do
      MachoBuck.count.should be == 1
      @bucks.user.should be == user
      user.total_macho_bucks.should == @bucks.amount
    end
    
    describe "admin adjustment" do      
      before { FactoryGirl.create(:macho_bucks_from_admin, :user => user, :amount => -macho_buck.amount) }
      
      it "should be back to zero" do
        MachoBuck.count.should be == 2
        user.reload.total_macho_bucks.should == 0
      end
    end
    
    describe "delete policy" do
      before { user.destroy }
      
      it "should also destroy macho bucks" do
        MachoBuck.count.should == 0
      end
    end    
  end
  
  describe "stripe logs" do
    let(:log) { FactoryGirl.create(:stripe_log, :user => user) }
    
    it "should be there" do
      log.user.id.should be == user.id
      user.stripe_logs.count.should be == 1
      user.stripe_logs.first.id.should be == log.id
      expect { user.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
        
    describe "delete logs first" do
      before { StripeLog.destroy_all }
      
      it "can delete now" do
        expect { user.reload.destroy }.to_not raise_exception
      end
    end
  end
  
  describe "Profile fields" do
    describe "missing optin" do
      before { user.optin = nil }
      
      it { should_not be_valid }
    end
    
    describe "first name too long" do
      before { user.first_name = "a" * (User::MAX_FIRST_NAME + 1) }
      
      it { should_not be_valid }
    end

    describe "last name too long" do
      before { user.last_name = "a" * (User::MAX_LAST_NAME + 1) }
      
      it { should_not be_valid }
    end
    
    describe "address 1 too long" do
      before { user.address_1 = "a" * (User::MAX_ADDRESS + 1) }
      
      it { should_not be_valid }
    end
    
    describe "address 2 too long" do
      before { user.address_2 = "a" * (User::MAX_ADDRESS + 1) }
      
      it { should_not be_valid }
    end
    
    describe "state" do 
      describe "validate against list" do
        ApplicationHelper::US_STATES.each do |state|
          before { user.state = state }
          
          it { should be_valid }
        end
        
        describe "invalid state" do
          before { user.state = "Not a state" }
          
          it { should_not be_valid }
        end
      end
    end

    describe "zip code (valid)" do
      ["13416", "15237", "15237"].each do |code|
        before { user.zipcode = code }
        
        it { should be_valid }
      end
    end
  
    describe "zip code (invalid)" do  
      ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
        before { user.zipcode = code }
       
        it { should_not be_valid }
      end
    end  
  
    describe "phone (valid)" do
      ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
        before { user.phone = phone }
        
        it { should be_valid }
      end
    end
  
    # Should actually introduce phone normalization if we want people to type them in
    # Many of these should be valid after normalization 
    describe "phone (invalid)" do  
      ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
        before { user.phone = phone }
       
        it { should_not be_valid }
      end
    end   
    
    describe "should not allow duplicate categories" do
      let(:category) { FactoryGirl.create(:category) }
      
      before { user.categories << category }
      
      it "should have a category" do
        user.categories.count.should == 1
      end
      
      it "no dups" do
        expect { user.categories << category }.to raise_exception(ActiveRecord::RecordNotUnique)
      end
    end   
  end
  
  describe "Vendor users" do
    let(:vendor) { FactoryGirl.create(:vendor, :user => user) }
    
    it "should point to the vendor" do
      # Need to access vendor to create it so the associations will be valid
      vendor.user.should be == user
      user.vendor.should == vendor
    end
    
    describe "updating attributes" do
      before do 
        @attr = vendor.attributes
        @attr['state'] = "MO"
        @attr['zip'] = "32432"
        # Can't set these
        @attr.delete('created_at')
        @attr.delete('updated_at')
        @attr.delete('slug')
        user.vendor_attributes = @attr
        user.save!
      end
      
      it "should update" do
        user.reload.vendor.state.should be == "MO"
        user.reload.vendor.zip.should == "32432"
      end
    end
    
    describe "Deleting associated user doesn't delete vendor" do
      before { user.destroy }
      
      it "should still have a vendor with no user" do
        vendor.reload.user.should be_nil
      end
    end
  end

  describe "duplicate email" do
    before { @user2 = user.dup }
    
    it "shouldn't allow exact duplicates" do
      @user2.should_not be_valid
    end
    
    describe "case sensitivity" do
      before do
        @user2 = user.dup
        @user2.email = user.email.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @user2.should_not be_valid
      end
    end
  end
  
  describe "roles" do
    it "should not have any roles" do
      Role::ROLES.each do |role|
        user.has_role?(role).should be_false
      end
      user.is_customer?.should be_true
    end
    
    describe "super admin" do
      let(:user) { FactoryGirl.create(:super_admin_user) }
      
      it { should be_valid }

      it "should be a super admin" do
        user.has_role?(Role::SUPER_ADMIN).should be_true
        user.is_customer?.should be_false
      end
    end

    describe "content admin" do
      let(:user) { FactoryGirl.create(:content_admin_user) }
      
      it { should be_valid }

      it "should be a content admin" do
        user.has_role?(Role::CONTENT_ADMIN).should be_true
        user.is_customer?.should be_false
      end
    end
    
    describe "merchant role" do
      let(:user) { FactoryGirl.create(:merchant_user) }
      
      it { should be_valid }

      it "should be a merchant" do
        user.has_role?(Role::MERCHANT).should be_true
        user.vendor.should_not be_nil
        user.is_customer?.should be_false
      end
    end

    describe "multiple roles" do
      let(:user) { FactoryGirl.create(:power_user) }
      
      it { should be_valid }

      it "should be everything" do
        user.is_customer?.should be_false
        
        Role::ROLES.each do |role|
          user.has_role?(role).should be_true
        end
      end
    end
  end  
  
  describe "should allow deletion if no orders" do
    it "should not have orders" do
      user.orders.count.should == 0
    end
    
    describe "delete" do
      before do
        @id = user.id
        user.destroy
      end
      
      it "should allow deletion" do
        expect { User.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  describe "orders" do
    let(:user) { FactoryGirl.create(:user_with_orders) }
    
    it { should be_valid }
    
    it "should have orders" do
      user.orders.count.should be == 3
      user.orders.each do |order|
        order.user.should == user
      end
    end
        
    describe "deleting the user doesn't delete orders" do
      before { @id = user.id }
      
      it "shouldn't allow deletion" do
        expect { user.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
        User.find(@id).should == user
      end
      
      it "should still have orders" do
        Order.all.count.should be == 3
        Order.find_by_user_id(@id).should_not be_nil
      end
    end
  end
  
  describe "vouchers" do
    let(:user) { FactoryGirl.create(:user_with_vouchers) }
    
    it { should be_valid }
    
    it "should have orders with vouchers" do
      user.orders.count.should be == 3
      user.orders.each do |order|
        order.user.should be == user
        order.vouchers.count.should be == 3
        order.vouchers.each do |voucher|
          voucher.order.should == order
        end
      end
    end
    
    describe "deleting the user doesn't delete the orders and vouchers" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with orders" do
        user.orders.count.should == 3
      end
      
      it "should start with vouchers" do
        user.vouchers.count.should == 9
      end
      
      describe "should not destroy associated orders and vouchers" do
        before do
          @id = user.id
          @orders = user.orders
          @vouchers = user.vouchers
        end
        
        it "shouldn't allow deletion" do
          expect { user.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
          User.find(@id).should == user
        end
        
        it "should not be gone" do
          @orders.each do |order|
            Order.find_by_id(order.id).should_not be_nil
          end
               
          @vouchers.each do |voucher|
            Voucher.find_by_id(voucher.id).should_not be_nil
          end
        end
        
        describe "If no vouchers, can delete orders" do
          before {
            @vouchers.each do |v| 
              v.destroy
            end
          }
          
          it "should have no vouchers" do
            Voucher.unscoped.reload.count.should == 0
          end
          
          describe "now can delete orders" do
            before { Order.destroy_all }
            
            it "should have no orders" do
              Order.unscoped.reload.count.should be == 0
              expect { Order.find(@orders[0]) }.to raise_exception(ActiveRecord::RecordNotFound)
            end
            
            describe "can now delete user" do
              before { user.reload.destroy }
              
              it "should allow deletion" do
                expect { User.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
              end
            end
          end
        end     
      end 
    end        
  end

  describe "activities" do
    let(:user) { FactoryGirl.create(:user_with_activities) }
    
    it { should respond_to(:activities) }
    
    it { should be_valid }
    
    it "should have activities" do
      user.activities.count.should be == 5
      user.activities.each do |activity|
        activity.user.should == user
      end
    end
    
    describe "deletion" do
      before { user.destroy }
      
      it "should have deleted them" do
        User.count.should be == 0
        Activity.count.should == 0
      end
    end
    
    describe "activity logs" do
      let(:promotion) { FactoryGirl.create(:promotion) }
      let(:activity) { user.activities.last }
      before { user.log_activity(promotion) }
      
      it "should have a log" do
        user.activities.count.should be == 6
        activity.activity_name.should be == promotion.class.name
        activity.activity_id.should == promotion.id
      end
    end  
  end
 
  describe "stripe id" do
    it "should not have an id" do
      user.stripe_id.should be_nil
      user.stripe_customer_obj.should be_nil
    end
    
    describe "bogus customer" do
      before do
        user.stripe_id = "bogus"
        user.save!
      end  
      
      it "should have an invalid stripe id" do
        user.stripe_id.should be == "bogus"
        user.stripe_customer_obj.should be_nil
      end
    end    
  end
  
  describe "Feedback" do
    let(:user) { FactoryGirl.create(:user_with_feedback) }
    
    it "should not allow deletion" do
      expect { user.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    describe "Delete order" do
      before { user.orders.destroy_all }
     
      it "should still not allow deletion because of feedback" do
        Order.count.should be == 0
        expect { user.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
      end

      describe "Delete feedback" do
        before { user.feedbacks.destroy_all }
       
        it "should allow it now" do
          Feedback.count.should == 0
        end
          
        describe "Final delete" do
          before do
            @id = user.id
            user.reload.destroy
          end
          
          it "should be gone" do
            expect { User.find(@id) }.to raise_exception(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end  
end
