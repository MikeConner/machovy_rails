class MetrosController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /metros
  def index
    @metros = Metro.all
  end

  # GET /metros/1
  def show
    @metro = Metro.find(params[:id])
  end

  # GET /metros/new
  def new
    @metro = Metro.new
  end

  # GET /metros/1/edit
  def edit
    @metro = Metro.find(params[:id])
  end

  # POST /metros
  def create
    @metro = Metro.new(params[:metro])
    if @metro.save
      redirect_to @metro, notice: 'Metro was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /metros/1
  def update
    @metro = Metro.find(params[:id])
    if @metro.update_attributes(params[:metro])
      redirect_to @metro, notice: 'Metro was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /metros/1
  def destroy
    @metro = Metro.find(params[:id])
    @metro.destroy

    redirect_to metros_path
  end
end
