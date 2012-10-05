class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:about]

  def about
  end
  
  def admin_index
    authorize! :access, :rails_admin
  end
  
  def reports
    authorize! :access, :rails_admin    
  end
end
