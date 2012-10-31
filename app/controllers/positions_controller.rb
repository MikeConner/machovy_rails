# Currently unused, but will be someday
class PositionsController < ApplicationController
  load_and_authorize_resource
  
  # GET /positions
  def index
    @positions = Position.all
  end

  # GET /positions/1
  def show
    @position = Position.find(params[:id])
  end

  # GET /positions/new
  def new
    @position = Position.new
  end

  # GET /positions/1/edit
  def edit
    @position = Position.find(params[:id])
  end

  # POST /positions
  def create
    @position = Position.new(params[:position])
    if @position.save
      redirect_to @position, notice: 'Position was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /positions/1
  def update
    @position = Position.find(params[:id])
    if @position.update_attributes(params[:position])
      redirect_to @position, notice: 'Position was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /positions/1
  def destroy
    @position = Position.find(params[:id])
    @position.destroy

    redirect_to positions_path
  end
end
