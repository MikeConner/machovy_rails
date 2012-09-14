class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.order(:grid_weight)


    # add code to make sure only active categories come back!!! [ARASH!]
  end
end
