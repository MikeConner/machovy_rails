class PromotionImagesController < ApplicationController
  # GET /promotion_images
  # GET /promotion_images.json
  def index
    @promotion_images = PromotionImage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @promotion_images }
    end
  end

  # GET /promotion_images/1
  # GET /promotion_images/1.json
  def show
    @promotion_image = PromotionImage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @promotion_image }
    end
  end

  # GET /promotion_images/new
  # GET /promotion_images/new.json
  def new
    @promotion_image = PromotionImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @promotion_image }
    end
  end

  # GET /promotion_images/1/edit
  def edit
    @promotion_image = PromotionImage.find(params[:id])
  end

  # POST /promotion_images
  # POST /promotion_images.json
  def create
    @promotion_image = PromotionImage.new(params[:promotion_image])

    respond_to do |format|
      if @promotion_image.save
        format.html { redirect_to @promotion_image, notice: 'Promotion image was successfully created.' }
        format.json { render json: @promotion_image, status: :created, location: @promotion_image }
      else
        format.html { render action: "new" }
        format.json { render json: @promotion_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /promotion_images/1
  # PUT /promotion_images/1.json
  def update
    @promotion_image = PromotionImage.find(params[:id])

    respond_to do |format|
      if @promotion_image.update_attributes(params[:promotion_image])
        format.html { redirect_to @promotion_image, notice: 'Promotion image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @promotion_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promotion_images/1
  # DELETE /promotion_images/1.json
  def destroy
    @promotion_image = PromotionImage.find(params[:id])
    @promotion_image.destroy

    respond_to do |format|
      format.html { redirect_to promotion_images_url }
      format.json { head :no_content }
    end
  end
end
