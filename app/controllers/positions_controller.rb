class PositionsController < ApplicationController
  load_and_authorize_resource
  
  # GET /careers
  # GET /careers.json
  def index
    @positions = Career.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @positions }
    end
  end

  # GET /careers/1
  # GET /careers/1.json
  def show
    @position = Career.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @position }
    end
  end

  # GET /careers/new
  # GET /careers/new.json
  def new
    @position = Career.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @position }
    end
  end

  # GET /careers/1/edit
  def edit
    @position = Career.find(params[:id])
  end

  # POST /careers
  # POST /careers.json
  def create
    @position = Career.new(params[:position])

    respond_to do |format|
      if @position.save
        format.html { redirect_to @position, notice: 'Position was successfully created.' }
        format.json { render json: @position, status: :created, location: @position }
      else
        format.html { render action: "new" }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /careers/1
  # PUT /careers/1.json
  def update
    @position = Career.find(params[:id])

    respond_to do |format|
      if @position.update_attributes(params[:career])
        format.html { redirect_to @position, notice: 'Position was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /careers/1
  # DELETE /careers/1.json
  def destroy
    @position = Career.find(params[:id])
    @position.destroy

    respond_to do |format|
      format.html { redirect_to positions_url }
      format.json { head :no_content }
    end
  end
end
