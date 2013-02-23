class CouponsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :ensure_admin, :except => [:show]
  before_filter :transform_prices, :only => [:create, :update]

  def new
    @coupon = Coupon.new
    @vendors = Vendor.all
    
    render :layout => 'layouts/admin'
  end
  
  def create
    @coupon = Coupon.new(params[:coupon])
    if @coupon.save
      redirect_to @coupon, notice: 'Coupon was successfully created.'
    else
      @vendors = Vendor.all
      render 'new', :layout => 'layouts/admin'
    end    
  end
  
  def edit
    @coupon = Coupon.find(params[:id])
    @vendors = Vendor.all
    render :layout => 'layouts/admin'    
  end
  
  def update
    @coupon = Coupon.find(params[:id])
    if @coupon.update_attributes(params[:coupon])
      redirect_to @coupon, notice: 'Coupon was successfully updated.'
    else
      @vendors = Vendor.all
      render 'edit', :layout => 'layouts/admin'
    end    
  end
  
  def show
    @coupon = Coupon.find(params[:id])
    if admin_user?
      render :layout => 'layouts/admin'
    else
      # Show who's printing out coupons
      current_user.log_activity(@coupon)
    end
  end
  
  def index
    @coupons = Coupon.order('updated_at desc')
    
    render :layout => 'layouts/admin'    
  end
  
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy
    
    redirect_to coupons_path, :notice => 'Coupon successfully deleted'
  end
private
  def transform_prices
    if !params[:coupon].nil? 
      params[:coupon][:value].gsub!('$', '') unless params[:coupon][:value].nil?
    end    
  end
  
  def ensure_admin
    if !admin_user?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end