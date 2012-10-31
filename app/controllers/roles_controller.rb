# Currently unused, but may be
class RolesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  # GET /roles
  def index
    @roles = Role.all
  end

  # GET /roles/1
  def show
    @role = Role.find(params[:id])
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to @role, notice: 'Role was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /roles/1
  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      redirect_to @role, notice: 'Role was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /roles/1
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    redirect_to roles_path
  end
end
