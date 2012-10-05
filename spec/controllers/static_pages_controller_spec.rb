describe StaticPagesController do
  include Devise::TestHelpers

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
  end
end
