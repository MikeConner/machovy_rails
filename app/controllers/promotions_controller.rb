class PromotionsController < ApplicationController

  # GET /promotions
  # GET /promotions.json
  def index
    @promotions = Promotion.all
    @categories = Category.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @promotions }
    end
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    @promotion = Promotion.find(params[:id])
    @categories = Category.all
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @promotion }
    end
  end


  # GET /promotions/1/order
  # GET /promotions/1/order???.json
  def order
    @promotion = Promotion.find(params[:id])
    @order = @promotion.orders.new
    @order.prepare_for current_user
    @categories = Category.all
    
    
    respond_to do |format|
      format.html # order.html.erb
#      format.json { render json: @promotion }
    end
  end


  


  # GET /promotions/new
  # GET /promotions/new.json
  def new
    @promotion = Promotion.new
    @categories = Category.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @promotion }
    end
  end

  # GET /promotions/1/edit
  def edit
    @promotion = Promotion.find(params[:id])
  end

  # POST /promotions
  # POST /promotions.json
  def create
    @promotion = Promotion.new(params[:promotion])
    @categories = Category.all

    respond_to do |format|
      if @promotion.save
        format.html { redirect_to @promotion, notice: 'Promotion was successfully created.' }
        format.json { render json: @promotion, status: :created, location: @promotion }
      else
        format.html { render action: "new" }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /promotions/1
  # PUT /promotions/1.json
  def update
    @promotion = Promotion.find(params[:id])
    @categories = Category.all

    respond_to do |format|
      if @promotion.update_attributes(params[:promotion])
        format.html { redirect_to @promotion, notice: 'Promotion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy
    @categories = Category.all

    respond_to do |format|
      format.html { redirect_to promotions_url }
      format.json { head :no_content }
    end
  end
end
