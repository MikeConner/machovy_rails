class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:about, :mailing, :get_featured]
  
  def about
  end
  
  def admin_index
  end

  def get_featured
	end
	
  # NOTE: This is temporary, just to demonstrate the connection
  def mailing
    gb = Gibbon.new
    @lists = Hash.new
    for i in 1..gb.lists['total'] do
      list_id = gb.lists['data'][i - 1]['id']
      name = gb.lists['data'][i - 1]['name']
      @lists[name] = []
      members = gb.list_members({:id => list_id})
      members['data'].map { |m| @lists[name].push(m['email']) }
    end
  end
end
