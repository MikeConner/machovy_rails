# == Schema Information
#
# Table name: promotion_images
#
#  id               :integer         not null, primary key
#  caption          :string(64)
#  media_type       :string(16)
#  slideshow_image  :string(255)
#  remote_image_url :string(255)
#  promotion_id     :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

describe "PromotionImages" do
  let(:promotion) { FactoryGirl.create(:promotion) }
  let(:image) { FactoryGirl.create(:promotion_image, :promotion => promotion) }
  
  subject { image }
  
  it { should respond_to(:caption) }
  it { should respond_to(:slideshow_image) }
  it { should respond_to(:remote_image_url) }
  
  its(:promotion) { should == promotion }
  
  it { should be_valid }
  
  describe "blank caption" do
    before { image.caption = " " }
    
    it { should be_valid }
  end
  
  describe "caption too long" do
    before { image.caption = "a"*(PromotionImage::MAX_CAPTION_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "no image" do
    let(:image) { promotion.promotion_images.build }
    
    it { should_not be_valid }
  end
  
  # NOTE: Can't really unit test the upload logic, since it requires uploading through the controllers.
  #   Just setting the string field doesn't work  
end
