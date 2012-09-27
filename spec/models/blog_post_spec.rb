describe "Blog posts" do
  let(:curator) { FactoryGirl.create(:curator) }
  let(:post) { FactoryGirl.create(:blog_post, :curator => curator, :metro => curator.metro) }
  
  subject { post }
  
  it { should respond_to(:body) }
  it { should respond_to(:posted_at) }
  it { should respond_to(:title) }
  it { should respond_to(:weight) }
  
  its(:curator) { should == curator }
  its(:metro) { should == curator.metro }
  
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
        @ids.push(FactoryGirl.create(:blog_post, :curator => curator, :metro => curator.metro, :weight => @current_weight))
      end
    end
  end
end
