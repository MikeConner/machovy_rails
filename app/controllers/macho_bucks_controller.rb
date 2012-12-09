class MachoBucksController < ApplicationController
  before_filter :authenticate_user!, :except => [:about]
  before_filter :ensure_admin, :except => [:about]
  load_and_authorize_resource :except => [:about]
  
  def index    
    render :layout => 'layouts/admin'
  end
  
  def create
    @macho_bucks = MachoBuck.new(params[:macho_buck])

    if @macho_bucks.save
      flash.now[:notice] = 'Macho Bucks transaction successful'
    else
      flash.now[:alert] = 'Error creating macho bucks transaction'
    end  
    
    @user = User.find(params[:macho_buck][:user_id])
    render 'index', :layout => 'layouts/admin'   
  end
  
  def search
    @user = User.find_by_email(params[:email])
    
    render 'index', :layout => 'layouts/admin'   
  end
  
  def about
  end
  
private
  def ensure_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end