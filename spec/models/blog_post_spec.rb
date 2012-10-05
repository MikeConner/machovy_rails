# == Schema Information
#
# Table name: blog_posts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :text
#  curator_id :integer
#  posted_at  :datetime
#  weight     :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  slug       :string(255)
#

describe "Blog posts" do
  let(:curator) { FactoryGirl.create(:curator) }
  let(:post) { FactoryGirl.create(:blog_post, :curator => curator) }
  
  subject { post }
  
  it { should respond_to(:body) }
  it { should respond_to(:posted_at) }
  it { should respond_to(:title) }
  it { should respond_to(:weight) }
  it { should respond_to(:promotions) }
  
  its(:curator) { should == curator }
  
  it { should be_valid }
  
  describe "weight validation" do
    before { post.weight = 0 }
    
    it { should_not be_valid }
    
    describe "fractional weight" do
      before { post.weight = 0.5 }
      
      it { should_not be_valid }
      
      describe "negative weight" do
        before { post.weight = -5 }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "sort order" do
    before do
      @ids = [post.id]
      @current_weight = post.weight
      
      5.times do 
        @ids.push(FactoryGirl.create(:blog_post, :curator => curator, :weight => @current_weight))
      end
    end
  end
  
  describe "promotions" do
    let(:post) { FactoryGirl.create(:blog_post_with_promotions, :curator => curator) }
    
    it "should have promotions" do
      post.promotions.count.should == 5
      post.promotions.each do |p| 
        p.blog_posts.include?(post).should be_true
      end
    end
    
    it "should not allow duplicate assignments" do
      expect { post.promotions << post.promotions[0] }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    
    describe "should still have promotions after destroy" do
      before { post.destroy }
      
      it "promotions should exist but not have any posts" do
        Promotion.count.should == 5
        Promotion.all.each do |p|
          p.blog_posts.count.should == 0
        end
      end
    end
  end
end
