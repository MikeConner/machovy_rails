class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:about]

  def about
  end
  
  def admin_index
    authorize! :access, :rails_admin
  end

  # Is this merchant reports (in which case we don't need it) or something else? 
  def reports
    authorize! :access, :rails_admin    
  end
end
