class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.order(:grid_weight).limit(8)
      @blog_posts = BlogPost.order(:weight).limit(3)
    

    # add code to make sure only active categories come back!!! [ARASH!]
  end
end
