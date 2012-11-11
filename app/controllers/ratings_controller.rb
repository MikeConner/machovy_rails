class RatingsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    begin
      if @rating.update_attributes(params[:rating])
        flash[:notice] = I18n.t('rating_success')
      else
        # Creating a rating can generate an error if you're trying to rate your own idea
        # I think it would look silly to try to render error messages in the rating form,
        #   plus it's technically difficult because I'm building it on the spot and it would
        #   be tricky to preserve it.
        # So I'm copying the error out of the object and displaying it on the feedback page's flash
        flash[:alert] = ''
        
        @rating.errors.full_messages.each do |msg|
          flash[:alert] += msg + "\n"
        end
      end
    rescue
      flash[:alert] = I18n.t('already_rated')
    end
    
    redirect_to feedback_path
  end
end