class FrontGridController < ApplicationController
  def index
    @promotions = Promotion.active.limit(8)
    # Will be ordered by default scope
    @blog_posts = BlogPost.limit(4)
    @ads = Promotion.ads.limit(5)

    # add code to make sure only active categories come back!!! [ARASH!]
  end
end
