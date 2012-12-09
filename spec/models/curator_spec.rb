# == Schema Information
#
# Table name: curators
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  picture    :string(255)
#  bio        :text
#  twitter    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  slug       :string(255)
#  title      :string(48)
#

describe "Curators" do
  let(:curator) { FactoryGirl.create(:curator) }
  
  subject { curator }

  it "should respond to everything" do
    curator.should respond_to(:blog_posts)
    curator.should respond_to(:promotions)
    curator.should respond_to(:picture)
    curator.should respond_to(:name)
    curator.should respond_to(:twitter)
    curator.should respond_to(:bio)
    curator.should respond_to(:title)
    curator.should respond_to(:recent_posts)
    curator.should respond_to(:blog_posts_for)
    curator.should respond_to(:twitter_path)
    curator.should respond_to(:videos)
  end
  
  it { should be_valid }
  
  describe "name validation" do
    before { curator.name = "  "}
    
    it { should_not be_valid }
  end
  
  describe "title validation" do
    before { curator.title = "  "}
    
    it { should_not be_valid }
    
    describe "too long" do
      before { curator.title = "a"*(Curator::MAX_TITLE_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  it "should calculate twitter path" do
    curator.twitter_path.should match('www.twitter.com')
    curator.twitter_path.should match(curator.twitter[1, curator.twitter.length - 1])
  end
  
  describe "videos" do
    let(:curator) { FactoryGirl.create(:curator_with_videos) }
    
    it { should be_valid }
    
    it "should have videos" do
      curator.videos.count.should be == 5
      curator.videos.each do |video|
        video.curator.should == curator
      end
    end
    
    describe "deleting the curator doesn't delete videos" do
      it "should start with videos" do
        curator.videos.count.should == 5
      end
      
      it "should not destroy associated videos" do
        videos = curator.videos
        curator.destroy
        videos.each do |v|
          Video.find_by_id(v.id).should_not be_nil
          Video.find_by_id(v.id).curator.should be_nil
        end
      end     
    end     
  end
  
  describe "duplicate names" do
    before { @curator2 = curator.dup }
    
    it "shouldn't allow exact duplicates" do
      @curator2.should_not be_valid
    end
    
    describe "case sensitivity" do
      before do
        @curator2 = curator.dup
        @curator2.name = curator.name.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @curator2.should_not be_valid
      end
    end
  end
  
  describe "bio validation" do
    before { curator.bio = " " }
    
    it { should_not be_valid }
  end

  describe "twitter validation" do
    before do 
      curator.twitter = " "
    end
    
    it { should_not be_valid }
  
    ["No_@_Sign", "@" + "t"*Curator::MAX_TWITTER_LEN, "Has space", "@Other+Invalid-"].each do |address|
      describe "format '#{address}'" do
        before { curator.twitter = address }
        
        it { should_not be_valid }
      end
    end
    
    describe "duplicate twitters" do
      before do
        @curator2 = curator.dup
        @curator2.twitter = curator.twitter.upcase
      end
      
      it "shouldn't allow case variant twitter duplicates" do
        @curator2.should_not be_valid
      end
    end
  end
  
  describe "blog posts" do
    let(:curator) { FactoryGirl.create(:curator_with_blog_posts) }
    
    it { should be_valid }
    
    it "should have posts" do
      curator.blog_posts.count.should be == 6
      curator.blog_posts.each do |p|
        p.curator.should be == curator
        p.metro.should == metro
      end
    end
    
    describe "should validate blog posts" do
      before { curator.reload.blog_posts[0].update_attributes(:title => "") }
      
      it { should_not be_valid }
    end
    
    describe "deleting the curator nullifies the blog posts" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with posts" do
        curator.blog_posts.count.should == 6
      end
      
      it "should nullify associated posts" do
        posts = curator.blog_posts
        curator.destroy
        posts.each do |p|
          bp = BlogPost.find_by_id(p.id)
          bp.should_not be_nil
          bp.curator.should be_nil
       end     
     end 
    end
  end
  
  describe "blog posts for" do
    let(:post1) { FactoryGirl.create(:blog_post_with_promotions) }
    let(:post2) { FactoryGirl.create(:blog_post_with_promotions) }
    let(:post3) { FactoryGirl.create(:blog_post_with_promotions) }
    let(:promotion) { FactoryGirl.create(:promotion) }
    # Create 2 blog posts with different curators
    # Create one promotion and assign to both posts
    # blog_posts_for should only return the blog post from the given curator associated with that promotion
    # Ignoring other blog posts and other promotions
    before do
      post1.promotions << promotion
      post2.promotions << promotion
    end
    
    it "should find the promotion for the first curator" do
      post1.curator.reload.blog_posts_for(promotion).should be == [post1]
      post2.curator.reload.blog_posts_for(promotion).should be == [post2]
      post3.curator.reload.blog_posts_for(promotion).should be_empty
    end
  end

  describe "scopes" do
    # Create 1 post, then MAX_POSTS addition ones, at 3 second intervals
    # Should bring back top 4 posts, and not include the first one
    before do
      @first_post = FactoryGirl.create(:blog_post, :curator => curator)
      curator.blog_posts << @first_post
      sleep 1
      
      Curator::MAX_POSTS.times do
        curator.blog_posts << FactoryGirl.create(:blog_post, :curator => curator)
        sleep 3
      end
    end
    
    it "should not show oldest post" do
      curator.recent_posts.count.should be == Curator::MAX_POSTS
      curator.recent_posts.include?(@first_post).should be_false
    end
    
    it "should show them in order" do
      curator.recent_posts.should == curator.blog_posts[1, Curator::MAX_POSTS].reverse
    end
  end

  describe "promotions" do
    let(:curator) { FactoryGirl.create(:curator_with_promotions) }
    
    it { should be_valid }
        
    it "should have promotions" do
      curator.promotions.count.should == 20
    end
    
    describe "deleting the curator doesn't delete promotions" do
      it "should start with promotions" do
        curator.promotions.count.should == 20
      end
      
      it "should not destroy associated promotions" do
        promotions = curator.promotions
        curator.destroy
        promotions.each do |p|
          Promotion.find_by_id(p.id).should_not be_nil
        end
      end     
    end 
  end  
end
