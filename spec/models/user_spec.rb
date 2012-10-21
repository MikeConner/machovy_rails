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
#

describe "Users" do
  let (:user) { FactoryGirl.create(:user) }
  
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
  
  it { should be_valid }

  describe "Vendor users" do
    let (:vendor) { FactoryGirl.create(:vendor, :user => user) }
    
    it "should point to the vendor" do
      # Need to access vendor to create it so the associations will be valid
      vendor.user.should == user
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
        user.vendor_attributes = @attr
        user.save!
      end
      
      it "should update" do
        user.reload.vendor.state.should == "MO"
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
      
      it { should respond_to(:email) }
      it { should respond_to(:password) }
      it { should respond_to(:password_confirmation) }
      it { should respond_to(:remember_me) }

      it { should respond_to(:orders) }
      it { should respond_to(:vouchers) }
      it { should respond_to(:roles) }
      
      it { should be_valid }

      it "should be a super admin" do
        user.has_role?(Role::SUPER_ADMIN).should be_true
        user.is_customer?.should be_false
      end
    end

    describe "content admin" do
      let(:user) { FactoryGirl.create(:content_admin_user) }
      
      it { should respond_to(:email) }
      it { should respond_to(:password) }
      it { should respond_to(:password_confirmation) }
      it { should respond_to(:remember_me) }
    
      it { should respond_to(:orders) }
      it { should respond_to(:vouchers) }
      it { should respond_to(:roles) }

      it { should be_valid }

      it "should be a content admin" do
        user.has_role?(Role::CONTENT_ADMIN).should be_true
        user.is_customer?.should be_false
      end
    end
    
    describe "merchant role" do
      let(:user) { FactoryGirl.create(:merchant_user) }
      
      it { should respond_to(:email) }
      it { should respond_to(:password) }
      it { should respond_to(:password_confirmation) }
      it { should respond_to(:remember_me) }
    
      it { should respond_to(:orders) }
      it { should respond_to(:vouchers) }
      it { should respond_to(:roles) }

      it { should be_valid }

      it "should be a merchant" do
        user.has_role?(Role::MERCHANT).should be_true
        user.is_customer?.should be_false
      end
    end

    describe "multiple roles" do
      let(:user) { FactoryGirl.create(:power_user) }
      
      it { should respond_to(:email) }
      it { should respond_to(:password) }
      it { should respond_to(:password_confirmation) }
      it { should respond_to(:remember_me) }
    
      it { should respond_to(:orders) }
      it { should respond_to(:vouchers) }
      it { should respond_to(:roles) }

      it { should be_valid }

      it "should be everything" do
        user.has_role?(Role::SUPER_ADMIN).should be_true
        user.has_role?(Role::CONTENT_ADMIN).should be_true
        user.has_role?(Role::MERCHANT).should be_true
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
    
    it { should respond_to(:email) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:remember_me) }
  
    it { should respond_to(:orders) }
    it { should respond_to(:vouchers) }
    it { should respond_to(:roles) }

    it { should be_valid }
    
    it "should have orders" do
      user.orders.count.should == 3
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
        Order.all.count.should == 3
        Order.find_by_user_id(@id).should_not be_nil
      end
    end
  end
  
  describe "vouchers" do
    let(:user) { FactoryGirl.create(:user_with_vouchers) }
    
    it { should respond_to(:email) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:remember_me) }
  
    it { should respond_to(:orders) }
    it { should respond_to(:vouchers) }
    it { should respond_to(:roles) }

    it { should be_valid }
    
    it "should have orders with vouchers" do
      user.orders.count.should == 3
      user.orders.each do |order|
        order.user.should == user
        order.vouchers.count.should == 3
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
              Order.unscoped.reload.count.should == 0
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
        user.stripe_id.should == "bogus"
        user.stripe_customer_obj.should be_nil
      end
    end    
  end
end
