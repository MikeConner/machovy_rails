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
