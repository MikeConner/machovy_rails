class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.order(:grid_weight)
    @categories = Category.all

    # add code to make sure only active categories come back!!! [ARASH!]
  end
end
