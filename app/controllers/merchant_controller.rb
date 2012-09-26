class MerchantController < ApplicationController
  before_filter :authenticate_user!, :except => [:some_action_without_auth]
  def MyDeals
    @vendors = current_user.vendors.all
    if @vendors.size > 0 
        @promotions = current_user.vendors.first.promotions.deal.order(:id)
        #right now we only have one vendor per user.  This may change in the future!
    end
  end

  def reports
  end

  def payments
  end

  def dashboard
  end
end
