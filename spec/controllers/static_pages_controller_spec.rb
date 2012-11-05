# I don't think we really need specific controller/view tests. Everything can be done in /models and /requests
# There is some interaction with Devise here that's making these fail
describe StaticPagesController do
  # Need this line to actually get content; by default it just returns status but doesn't render anything, so the pages would all be blank
  render_views
  
  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
      response.should have_selector('h1', :text => 'StaticPages#about')
    end
  end

  describe "GET 'admin index'" do
    it "returns http success" do
      get 'admin_index'
      response.should be_success
    end
  end

  describe "GET 'mailing'" do
    it "returns http success" do
      get 'mailing'
      response.should be_success
      response.should have_selector('h1', :text => 'MailChimp lists')
      response.should have_selector('h2', :text => 'All Customers')
    end
  end
end
