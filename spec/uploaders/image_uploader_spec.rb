require 'carrierwave/test/matchers'

describe "ImageFileUploader" do
  include Devise::TestHelpers
  include CarrierWave::Test::Matchers

  let(:image) { FactoryGirl.create(:image) }
  
  before do
#    ImageFileUploader.enable_processing = true
    @user = FactoryGirl.create(:user)
    sign_in @user
    @uploader = ImageFileUploader.new(@user, image)
    @uploader.store!(File.open("#{Rails.root}/tmp/"))
  end

  after do
    @uploader.remove!
#    ImageFileUploader.enable_processing = false
  end

  context 'the teaser version' do
    it "should resize to a teaser image for the front grid" do
      @uploader.teaser.should have_dimensions(470, 470)
    end
  end
end