class MetrosController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :ensure_admin
  load_and_authorize_resource

  # GET /metros
  def index
    @metros = Metro.order(:name)
    render :layout => 'layouts/admin'
  end

  # GET /metros/1
  def show
    @metro = Metro.find(params[:id])
  end

  # GET /metros/new
  def new
    @metro = Metro.new
    render :layout => 'layouts/admin'
  end

  # GET /metros/1/edit
  def edit
    @metro = Metro.find(params[:id])
    render :layout => 'layouts/admin'
  end

  # POST /metros
  def create
    @metro = Metro.new(params[:metro])
    if @metro.save
      redirect_to @metro, notice: 'Metro was successfully created.'
    else
      render 'new', :layout => 'layouts/admin'
    end
  end

  # PUT /metros/1
  def update
    @metro = Metro.find(params[:id])
    if @metro.update_attributes(params[:metro])
      redirect_to @metro, notice: 'Metro was successfully updated.'
    else
      render 'edit', :layout => 'layouts/admin'
    end
  end

  # DELETE /metros/1
  def destroy
    @metro = Metro.find(params[:id])
    @metro.destroy

    redirect_to metros_path
  end
  
private
  def ensure_admin
    if !admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end
