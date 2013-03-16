class SessionsController < Devise::SessionsController
  # DELETE /resource/sign_out
  def destroy
    # Copy session data so that we don't reload
    layout = session[:layout]
    page_start = session[:page_start]
    page_end = session[:page_end]
    num_columns = session[:num_columns]
    width = session[:width]

    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out

    session[:layout] = layout
    session[:page_start] = page_start
    session[:page_end] = page_end
    session[:num_columns] = num_columns
    session[:width] = width

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        head :no_content
      end
    end
  end
  
end