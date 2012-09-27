class DealsController < ApplicationController

  def index
    @promotions = Promotion.order(:grid_weight)
    #need to add in pagination here
    
  end
end
