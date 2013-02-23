# Currently unused, but might be later
class VideosController < ApplicationController
  load_and_authorize_resource

  include ApplicationHelper
  
  # GET /videos
  def index
    @curators = Curator.all
    if admin_user?
      render :layout => 'layouts/admin'
    end
  end

  # GET /videos/1
  def show
    @video = Video.find(params[:id])
  end

  # GET /videos/new
  def new
    @video = Video.new
    render :layout => 'layouts/admin'
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])
    render :layout => 'layouts/admin'
  end

  # POST /videos
  def create
    @video = Video.new(params[:video])
    if @video.save
      redirect_to @video, notice: 'Video was successfully created.'
    else
      render 'new', :layout => 'layouts/admin'
    end
  end

  # PUT /videos/1
  def update
    @video = Video.find(params[:id])
    if @video.update_attributes(params[:video])
      redirect_to @video, notice: 'Video was successfully updated.'
    else
      render 'edit', :layout => 'layouts/admin'
    end
  end

  # DELETE /videos/1
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    redirect_to videos_path, :notice => 'Video successfully deleted'
  end
end
