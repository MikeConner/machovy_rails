class CuratorsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  load_and_authorize_resource

  # GET /curators
  def index
    @curators = Curator.all
  end

  # GET /curators/1
  def show
    @curator = Curator.find(params[:id])
    @deals_per_row = 4
    promos = []
    @curator.blog_posts.each do |post|
      promos = promos | post.promotions
    end
    @promotions = promos.uniq
    @videos = @curator.videos
    
    if !current_user.nil? and current_user.is_customer?
      current_user.log_activity(@curator)
    end
  end

  # GET /curators/new
  def new
    @curator = Curator.new
  end

  # GET /curators/1/edit
  def edit
    @curator = Curator.find(params[:id])
  end

  # POST /curators
  def create
    @curator = Curator.new(params[:curator])
    if @curator.save
      redirect_to @curator, notice: 'Curator was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /curators/1
  def update
    @curator = Curator.find(params[:id])
    if @curator.update_attributes(params[:curator])
      redirect_to @curator, notice: 'Curator was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /curators/1
  def destroy
    @curator = Curator.find(params[:id])
    @curator.destroy

    redirect_to curators_path
  end
end
