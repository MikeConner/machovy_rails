class ExternalCouponsController < ApplicationController
  def show
    @coupon = ExternalCoupon.find(params[:id])
    if !current_user.nil?
      # Show who's clicking on coupons
      current_user.log_activity(@coupon)
    end
  end  
end