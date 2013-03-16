# == Schema Information
#
# Table name: blog_posts
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  body             :text
#  curator_id       :integer
#  activation_date  :datetime
#  weight           :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  slug             :string(255)
#  associated_image :string(255)
#

describe "Blog posts" do
  let(:curator) { FactoryGirl.create(:curator) }
  let(:post) { FactoryGirl.create(:blog_post, :curator => curator) }
  
  subject { post }
  
  it "should respond to everything" do
    post.should respond_to(:body)
    post.should respond_to(:activation_date)
    post.should respond_to(:title)
    post.should respond_to(:weight)
    post.should respond_to(:displayable?)
    post.should respond_to(:promotions)
    post.should respond_to(:metros)
    post.should respond_to(:<=>)
    post.should respond_to(:truncated_body)
    post.should respond_to(:associated_image)
    post.curator.should be == curator
  end
  
  it { should be_valid }
  it { should_not be_displayable }
  
  describe "no image" do
    before { post.remove_associated_image! }
    
    it { should_not be_valid }
  end
  
  describe "initialization" do
    before { @post = BlogPost.new }
    
    it "should have a default weight" do
      @post.weight.should == BlogPost::DEFAULT_BLOG_WEIGHT
    end
    
    it "should fill in the date" do
      @post.activation_date.should_not be_nil
    end
  end
  
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
      BlogPost.destroy_all
      @posts = FactoryGirl.create_list(:blog_post, 10)
      # No more default scope, so need to order them
      @weights = BlogPost.order(:weight).map { |n| n.weight }
    end
    
    it "should be ordered by weight" do
      # Make sure it's got them
      @weights.length.should be == 10
      @value = 0
      @weights.each do |w|
        w.should be >= @value
        @value = w
      end
    end
  end
  
  describe "displayable" do
    before { post.activation_date = 1.day.ago }
    
    it { should be_displayable }
  end
  
  describe "no activation date" do
    before { post.activation_date = nil }
    
    it { should be_displayable }
  end
  
  describe "body truncation" do
    it "should do default truncation" do
      post.truncated_body.should == post.body[0, 37] + "..."
    end
    
    it "should truncate shorter" do
      post.truncated_body(:length => 20).should == post.body[0, 17] + "..."
    end
    
    it "should truncate longer" do
      post.truncated_body(:length => 50).should == post.body[0, 47] + "..."
    end
    
    it "should take the whole thing" do
      post.truncated_body(:length => 5000).should == post.body
    end
    
    it "should return the whole thing if a string and < ellipsis length" do
      post.truncated_body(:length => 0).should be == post.body[0, post.body.length - 3] + "..."
      post.truncated_body(:length => 1).should be == post.body[0, post.body.length - 2] + "..."
      post.truncated_body(:length => 2).should be == post.body[0, post.body.length - 1] + "..."
      post.truncated_body(:length => 3).should be == "..."
    end
       
    it "should take the first character" do
      post.truncated_body(:length => 4).should == post.body[0] + "..."
    end
    
    it "should override the ellipsis" do
      post.truncated_body(:length => 20, :omission => "***").should == post.body[0, 17] + "***"
    end
    
    describe "HTML truncation" do
      before { post.body = '<p>This is a <b>sentence</b></p>'}
      
      it "should do default (< 40)" do
        post.truncated_body.should == post.body
      end
            
      it "should preserve tags" do
        post.truncated_body(:length => 0).should be == "..."
        post.truncated_body(:length => 1).should be == "<p>...</p>"
        post.truncated_body(:length => 2).should be == "<p>...</p>"
        post.truncated_body(:length => 3).should be == "<p>...</p>"
        post.truncated_body(:length => 4).should be == "<p>T...</p>"
        post.truncated_body(:length => 11).should be == "<p>This is a <b>...</b></p>"
      end
    end
  end

  describe "promotions" do
    let(:post) { FactoryGirl.create(:blog_post_with_promotions, :curator => curator) }
    
    it "should have promotions" do
      post.promotions.count.should be == 5
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
        Promotion.count.should be == 5
        Promotion.all.each do |p|
          p.blog_posts.count.should == 0
        end
      end
    end
  end
  
  describe "metros" do
    let(:post) { FactoryGirl.create(:blog_post_with_metro_promotions) }
    
    it "should have the right metros list" do
      post.metros.count.should be == 2
      post.metros.sort.should == Metro.all.sort
    end
  end
end
