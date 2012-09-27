class MembersareaController < ApplicationController
  before_filter :authenticate_user!, :except => [:some_action_without_auth]
  def show
  end
end
