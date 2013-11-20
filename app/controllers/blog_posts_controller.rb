require 'weighting_factory'

class BlogPostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource

  include ApplicationHelper

  # GET /blog_posts
  def index
    # Without default scope, need to explicitly order it
    @blog_posts = params[:unauthored].nil? ? BlogPost.order(:weight).paginate(:page => params[:page]) : 
                                             BlogPost.unauthored.order(:weight).paginate(:page => params[:page])
    if admin_user?
      @weights = @blog_posts.map { |p| p.weight }
      @diff = @weights.empty? ? 0 : @weights[@weights.length - 1] - @weights[0]
      # Large step
      @page_value = [1, @diff / 10].max.roundup
      # Small step
      @step_value = @page_value / 10
      
      render :layout => 'layouts/admin'
    end
  end

  # GET /blog_posts/1
  def show
    @blog_post = BlogPost.find(params[:id])
    
    if !current_user.nil? and current_user.is_customer?
      current_user.log_activity(@blog_post)
    end
    
    # Get associated promotions
    current_metro = Metro.find_by_name(session[:metro].blank? ? Metro::DEFAULT_METRO : session[:metro])
    
    @promotions = @blog_post.promotions.select { |p| p.displayable? and (p.metro.id == current_metro.id) }.sort
    if @promotions.count > 5
      @promotions = @promotions[0, 5]
    end
    @videos = @blog_post.curator.videos
  end

  # GET /blog_posts/new
  def new
    @blog_post = BlogPost.new
    render :layout => 'layouts/admin'
  end

  # GET /blog_posts/1/edit
  def edit
    @blog_post = BlogPost.find(params[:id])
    render :layout => 'layouts/admin'
  end

  # POST /blog_posts
  def create
    @blog_post = BlogPost.new(params[:blog_post])

    if @blog_post.save
      redirect_to @blog_post, notice: 'Blog post was successfully created.'
    else
      render 'new', :layout => 'layouts/admin'
    end
  end

  # PUT /blog_posts/1
  def update
    @blog_post = BlogPost.find(params[:id])

    if @blog_post.update_attributes(params[:blog_post])
      redirect_to @blog_post, notice: 'Blog post was successfully updated.'
    else
      render 'edit', :layout => 'layouts/admin'
    end
  end

  # DELETE /blog_posts/1
  def destroy
    @blog_post = BlogPost.find(params[:id])
    @blog_post.destroy

    redirect_to blog_posts_path
  end
  
  # PUT /blog_posts/1/update_weight
  def update_weight
    @blog_post = BlogPost.find(params[:id])
    old_weight = @blog_post.weight
    
    respond_to do |format|
      format.js do
        if @blog_post.update_attributes(params[:blog_post])
          head :ok
        else
          render :js => "alert('Weight update failed'); $('#blog_weight_#{params[:id]}').val(#{old_weight})"
        end
      end
    end    
  end
  
  def rebalance
    algorithm = WeightingFactory.instance.create_weighting_algorithm
    
    blog_weights = WeightingFactory.instance.create_weight_data(BlogPost.name)
    BlogPost.all.each { |post| blog_weights.add(post) }
    algorithm.reweight(blog_weights)
    BlogPost.all.each { |post| logger.info(blog_weights.save(post)) }    
    
    redirect_to blog_posts_path, :notice => 'Recalculated blog post weights'    
  end
end
