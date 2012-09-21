class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.where("description <> ''").order(:grid_weight).limit(8)
    @blog_posts = BlogPost.order(:weight).limit(4)
    @ads = Promotion.where("Trim(description) = '' or description is null").order(:grid_weight).limit(5)

    # add code to make sure only active categories come back!!! [ARASH!]
  end
end
