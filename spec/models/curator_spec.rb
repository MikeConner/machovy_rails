describe "Curators" do
  let(:user) { FactoryGirl.create(:user) }
  let(:metro) { FactoryGirl.create(:metro) }
  let(:curator) { FactoryGirl.create(:curator, :user => user, :metro => metro) }
  
  subject { curator }
  
  it { should respond_to(:user) }
  it { should respond_to(:metro) }
  it { should respond_to(:blog_posts) }
  it { should respond_to(:promotions) }
  it { should respond_to(:picture) }
  it { should respond_to(:name) }
  it { should respond_to(:twitter) }
  it { should respond_to(:bio) }
  
  its(:user) { should == user }
  its(:metro) { should == metro }
  
  it { should be_valid }
  
  describe "metro foreign key validation" do
    before { curator.metro = nil }
    
    it { should_not be_valid }
  end
  
  describe "user foreign key validation" do
    before { curator.user = nil }
    
    it { should_not be_valid }
  end
  
  describe "name validation" do
    before { curator.name = "  "}
    
    it { should_not be_valid }
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
    let(:metro) { FactoryGirl.create(:metro) }
    let(:user) { FactoryGirl.create(:user) }
    let(:curator) { FactoryGirl.create(:curator_with_blog_posts, :user => user, :metro => metro) }
    
    it { should respond_to(:user) }
    it { should respond_to(:metro) }
    it { should respond_to(:blog_posts) }
    it { should respond_to(:promotions) }
    it { should respond_to(:picture) }
    it { should respond_to(:name) }
    it { should respond_to(:twitter) }
    it { should respond_to(:bio) }
    
    its(:user) { should == user }
    its(:metro) { should == metro }

    it { should be_valid }
    
    it "should have posts" do
      curator.blog_posts.count.should == 6
      curator.blog_posts.each do |p|
        p.curator.should == curator
        p.metro.should == metro
      end
    end
    
    describe "deleting the curator deletes the blog posts" do
      # Make sure we're not "deleting" nothing and have a false positive
      it "should start with posts" do
        curator.blog_posts.count.should == 6
      end
      
      it "should destroy associated posts" do
        posts = curator.blog_posts
        curator.destroy
        posts.each do |p|
          BlogPost.find_by_id(p.id).should be_nil
       end     
     end 
    end
  end
  
  describe "promotions" do
    let(:metro) { FactoryGirl.create(:metro) }
    let(:user) { FactoryGirl.create(:user) }
    let(:curator) { FactoryGirl.create(:curator_with_promotions, :metro => metro, :user => user) }
    
    it { should respond_to(:user) }
    it { should respond_to(:metro) }
    it { should respond_to(:blog_posts) }
    it { should respond_to(:promotions) }
    it { should respond_to(:picture) }
    it { should respond_to(:name) }
    it { should respond_to(:twitter) }
    it { should respond_to(:bio) }
    
    its(:user) { should == user }
    its(:metro) { should == metro }

    it "should have promotions" do
      curator.promotions.count.should == 4
      curator.promotions.each do |p|
        p.curator.should == curator
        p.metro.should == metro
      end
    end
    
    describe "deleting the curator doesn't delete promotions" do
      it "should start with promotions" do
        curator.promotions.count.should == 4
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
