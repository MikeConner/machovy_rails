describe PromotionImagesController do
  include Devise::TestHelpers

  describe "imageurl" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    
    it "should upload a file" do
      @file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/M_logo.png'), 'image/png')
      post :create, :promotion_image => {:name => 'Logo', :imageurl => @file, :mediatype => 'image/png'}
      response.should be_success
    end
  end
end