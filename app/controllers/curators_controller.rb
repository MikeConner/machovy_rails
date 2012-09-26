class CuratorsController < ApplicationController
  before_filter :authenticate_user!, :except => [:some_action_without_auth]
  load_and_authorize_resource
  # GET /curators
  # GET /curators.json
  def index
    @curators = Curator.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @curators }
    end
  end

  # GET /curators/1
  # GET /curators/1.json
  def show
    @curator = Curator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @curator }
    end
  end

  # GET /curators/new
  # GET /curators/new.json
  def new
    @curator = Curator.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @curator }
    end
  end

  # GET /curators/1/edit
  def edit
    @curator = Curator.find(params[:id])
  end

  # POST /curators
  # POST /curators.json
  def create
    @curator = Curator.new(params[:curator])

    respond_to do |format|
      if @curator.save
        format.html { redirect_to @curator, notice: 'Curator was successfully created.' }
        format.json { render json: @curator, status: :created, location: @curator }
      else
        format.html { render action: "new" }
        format.json { render json: @curator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /curators/1
  # PUT /curators/1.json
  def update
    @curator = Curator.find(params[:id])

    respond_to do |format|
      if @curator.update_attributes(params[:curator])
        format.html { redirect_to @curator, notice: 'Curator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @curator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /curators/1
  # DELETE /curators/1.json
  def destroy
    @curator = Curator.find(params[:id])
    @curator.destroy

    respond_to do |format|
      format.html { redirect_to curators_url }
      format.json { head :no_content }
    end
  end
end
