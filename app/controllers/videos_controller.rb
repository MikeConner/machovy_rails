# Currently unused, but might be later
class VideosController < ApplicationController
  load_and_authorize_resource

  # GET /videos
  def index
    @videos = Video.all
  end

  # GET /videos/1
  def show
    @video = Video.find(params[:id])
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])
  end

  # POST /videos
  def create
    @video = Video.new(params[:video])
    if @video.save
      redirect_to @video, notice: 'Video was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /videos/1
  def update
    @video = Video.find(params[:id])
    if @video.update_attributes(params[:video])
      redirect_to @video, notice: 'Video was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /videos/1
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    redirect_to videos_path
  end
end
