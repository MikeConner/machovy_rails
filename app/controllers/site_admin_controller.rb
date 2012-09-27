class SiteAdminController < ApplicationController
  before_filter :authenticate_user!, :except => [:some_action_without_auth]
  def add_ad
      authorize! :access, :rails_admin
  end

  def add_deal
      authorize! :access, :rails_admin
  end

  def add_affiliate
      authorize! :access, :rails_admin
  end

  def add_vendor
      authorize! :access, :rails_admin
    render "vendor/new"
  end

  def add_metro
      authorize! :access, :rails_admin
  end

  def front_page
      authorize! :access, :rails_admin
  end

  def user_admin
      authorize! :access, :rails_admin
  end

  def merchant_admin
      authorize! :access, :rails_admin
  end

  def reports
      authorize! :access, :rails_admin
  end
  
  def index
      authorize! :access, :rails_admin
  end
  
end
