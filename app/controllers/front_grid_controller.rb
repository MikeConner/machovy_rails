class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.order(:grid_weight)
  end
end
