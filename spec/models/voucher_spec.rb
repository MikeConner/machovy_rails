# == Schema Information
#
# Table name: vouchers
#
#  id              :integer          not null, primary key
#  uuid            :string(255)
#  redemption_date :datetime
#  status          :string(16)       default("Available")
#  notes           :text
#  expiration_date :datetime
#  valid_date      :datetime
#  order_id        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  slug            :string(255)
#  payment_id      :integer
#  delay_hours     :integer
#

describe "Vouchers" do
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:user) { FactoryGirl.create(:user) }
  let(:order) { FactoryGirl.create(:order, :promotion => promotion, :user => user) }
  let(:voucher) { FactoryGirl.create(:voucher, :order => order) }
  
  subject { voucher }
  
  it "should respond to everything" do
    voucher.should respond_to(:expiration_date)
    voucher.should respond_to(:valid_date)
    voucher.should respond_to(:notes)
    voucher.should respond_to(:status)
    voucher.should respond_to(:uuid)
    voucher.should respond_to(:user)
    voucher.should respond_to(:order)
    voucher.should respond_to(:promotion)
    voucher.should respond_to(:redemption_date)
    voucher.should respond_to(:started?)
    voucher.should respond_to(:expired?)
    voucher.should respond_to(:open?)
    voucher.should respond_to(:redeemable?)
    voucher.should respond_to(:unredeemable?)
    voucher.should respond_to(:returnable?)
    voucher.should respond_to(:paid?)
    voucher.should respond_to(:payment_owed?)
    voucher.should respond_to(:payment)
    voucher.should respond_to(:macho_buck)
    voucher.should respond_to(:delay_hours)
    voucher.should respond_to(:earliest_redemption_time)
    voucher.should respond_to(:delay_passed?)
    voucher.order.should be == order
    voucher.user.should be == user
    voucher.promotion.should be == promotion
  end

  it { should be_valid }
  
  it "default to no delay" do
    voucher.delay_passed?.should be_true
    voucher.earliest_redemption_time.should be == voucher.created_at
    voucher.delay_hours.should be_nil   
  end
  
  describe "delay" do
    let(:voucher) { FactoryGirl.create(:voucher, :order => order, :delay_hours => 6) }
    
    it "should have a delay" do
      voucher.delay_hours.should be == 6
      voucher.delay_passed?.should be_false
      voucher.earliest_redemption_time.should_not be_nil
    end
    
    describe "zero is ok" do
      before { voucher.delay_hours = 0 }
      
      it { should be_valid }
    end
    
    describe "Invalid delay" do
      [-2, 1.5, 'abc'].each do |delay|
        before { voucher.delay_hours = delay }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "Product vouchers" do
    before do
      FactoryGirl.create(:product_promotion_with_voucher)
      @voucher = Voucher.last
    end
  
    it "should be redeemed, and not unredeemable" do
      @voucher.status.should be == Voucher::REDEEMED
      @voucher.redeemable?.should be_false
      @voucher.unredeemable?.should be_false
      @voucher.returnable?.should be_false
      @voucher.payment_owed?.should be_true
    end
  end
  
  describe "macho bucks" do
    let(:macho_buck) { FactoryGirl.create(:macho_bucks_from_voucher, :voucher => voucher) }
    before { macho_buck }
    
    it "should point to the bucks" do
      voucher.macho_buck.should == macho_buck
    end
  end
  
  describe "expiration date" do
    before { voucher.expiration_date = " " }
    
    it { should_not be_valid }
  end

  describe "valid date" do
    before { voucher.valid_date = " " }
    
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
      # Should create slug at the same time
      voucher.reload.slug.should == voucher.reload.uuid
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
          voucher.unredeemable?.should be_true
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
      voucher.in_redemption_period?.should be_true
    end
    
    describe "expired before issued" do
      before { voucher.expiration_date = voucher.valid_date - 1.day }
      
      it { should_not be_valid }
      it "should not be open" do
        voucher.open?.should be_false
      end
    end
    
    it "should not be expired" do
      voucher.expired?.should be_false
    end
    
    it "should be in redemption period" do
      voucher.in_redemption_period?.should be_true
      voucher.started?.should be_true
      voucher.expired?.should be_false
    end
    
    describe "expired" do
      before { voucher.expiration_date = 1.day.ago }
      
      it "should be expired" do
        voucher.expired?.should be_true
      end
    end
    
    describe "test future voucher" do
      before { voucher.valid_date = 1.week.from_now }
      
      it "should not be expired" do
        voucher.expired?.should be_false
      end
      
      it "should not be open" do
        voucher.in_redemption_period?.should be_false
        voucher.open?.should be_false
        voucher.started?.should be_false
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
