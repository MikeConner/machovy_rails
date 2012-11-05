class BlogPostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource

  # GET /blog_posts
  def index
    # Without default scope, need to explicitly order it
    @blog_posts = BlogPost.order(:weight)
  end

  # GET /blog_posts/1
  def show
    @blog_post = BlogPost.find(params[:id])
    
    if !current_user.nil? and current_user.is_customer?
      current_user.log_activity(@blog_post)
    end
    
    # Get associated promotions
    metro_id = Metro.find_by_name(session[:metro]).id
    @promotions = @blog_post.promotions.select { |p| p.displayable? and (p.metro.id == metro_id) }.sort
    if @promotions.count > 5
      @promotions = @promotions[0, 5]
    end
    @videos = @blog_post.curator.videos
  end

  # GET /blog_posts/new
  def new
    @blog_post = BlogPost.new
  end

  # GET /blog_posts/1/edit
  def edit
    @blog_post = BlogPost.find(params[:id])
  end

  # POST /blog_posts
  def create
    @blog_post = BlogPost.new(params[:blog_post])

    if @blog_post.save
      redirect_to @blog_post, notice: 'Blog post was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /blog_posts/1
  def update
    @blog_post = BlogPost.find(params[:id])

    if @blog_post.update_attributes(params[:blog_post])
      redirect_to @blog_post, notice: 'Blog post was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /blog_posts/1
  def destroy
    @blog_post = BlogPost.find(params[:id])
    @blog_post.destroy

    redirect_to blog_posts_path
  end
end
