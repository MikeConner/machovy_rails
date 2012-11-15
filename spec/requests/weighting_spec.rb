require 'weighting_factory'

describe "Weighting algorithm" do
  before { @algorithm = WeightingFactory.instance.create_weighting_algorithm }
  
  subject { @algorithm }

  it { should respond_to(:reweight) }
  
  describe "Default promotion weighting" do
    before do
      @promotion_weights = WeightingFactory.instance.create_weight_data(Promotion.name)
      FactoryGirl.create_list(:promotion, 10)
      Promotion.all.each { |promotion| @promotion_weights.add(promotion) }
      @algorithm.reweight(@promotion_weights)
      Promotion.all.each { |promotion| @promotion_weights.save(promotion) }
    end
    
    it "should order them" do
      last = 0
      Promotion.order(:grid_weight) do |promotion|
        promotion.grid_weight.should be > last
        last = promotion.grid_weight
      end
    end
  end

  describe "Default promotion weighting (no spacing)" do
    before do
      @promotion_weights = WeightingFactory.instance.create_weight_data(Promotion.name)
      FactoryGirl.create_list(:promotion, 10)
      Promotion.all.each { |promotion| @promotion_weights.add(promotion) }
      @algorithm.reweight(@promotion_weights, nil)
      Promotion.all.each { |promotion| @promotion_weights.save(promotion) }
    end
    
    it "should order them" do
      last = 0
      Promotion.order(:grid_weight) do |promotion|
        promotion.grid_weight.should be == last + 1
        last = promotion.grid_weight
      end
    end
  end
  
  describe "Promotion weighting" do
    before do
      @promotion_weights = WeightingFactory.instance.create_weight_data(Promotion.name)
      FactoryGirl.create_list(:promotion, 10)
      Promotion.update_all(:grid_weight => Promotion::DEFAULT_GRID_WEIGHT)
      Promotion.all.each { |promotion| @promotion_weights.add(promotion) }
      @algorithm.reweight(@promotion_weights, 5) # min_spacing
      Promotion.all.each { |promotion| @promotion_weights.save(promotion) }
    end
    
    it "should space them out" do
      weights = []
      val = 1
      10.times do
        weights.push(val)
        val += 5 # min_spacing
      end
      
      @promotion_weights.new_weight.values.should be == weights
      Promotion.order(:grid_weight).map { |promotion| promotion.grid_weight }.should == weights
    end
    
    describe "respace by 10" do
      before do
        @algorithm.reweight(@promotion_weights, 10) 
        Promotion.all.each { |promotion| @promotion_weights.save(promotion) }
      end
      
      it "should space them out more" do
        weights = []
        val = 1
        10.times do
          weights.push(val)
          val += 10 # min_spacing
        end
        
        @promotion_weights.new_weight.values.sort.should be == weights
        Promotion.order(:grid_weight).map { |promotion| promotion.grid_weight }.should == weights
      end
    end
  end  

  # BlogPosts
  describe "Default blog post weighting" do
    before do
      @post_weights = WeightingFactory.instance.create_weight_data(BlogPost.name)
      FactoryGirl.create_list(:blog_post, 10)
      BlogPost.all.each { |post| @post_weights.add(post) }
      @algorithm.reweight(@post_weights)
      BlogPost.all.each { |post| @post_weights.save(post) }
    end
    
    it "should order them" do
      last = 0
      BlogPost.order(:weight) do |post|
        post.weight.should be > last
        last = post.weight
      end
    end
  end

  describe "Default blog post weighting (no spacing)" do
    before do
      @post_weights = WeightingFactory.instance.create_weight_data(BlogPost.name)
      FactoryGirl.create_list(:blog_post, 10)
      BlogPost.all.each { |post| @post_weights.add(post) }
      @algorithm.reweight(@post_weights, nil)
      BlogPost.all.each { |post| @post_weights.save(post) }
    end
    
    it "should order them" do
      last = 0
      BlogPost.order(:weight) do |post|
        post.weight.should be == last + 1
        last = post.weight
      end
    end
  end
  
  describe "Blog Post weighting" do
    before do
      @post_weights = WeightingFactory.instance.create_weight_data(BlogPost.name)
      FactoryGirl.create_list(:blog_post, 10)
      BlogPost.update_all(:weight => BlogPost::DEFAULT_BLOG_WEIGHT)
      BlogPost.all.each { |post| @post_weights.add(post) }
      @algorithm.reweight(@post_weights, 5) # min_spacing
      BlogPost.all.each { |post| @post_weights.save(post) }
    end
    
    it "should space them out" do
      weights = []
      val = 1
      10.times do
        weights.push(val)
        val += 5 # min_spacing
      end
      
      @post_weights.new_weight.values.should be == weights
      BlogPost.order(:weight).map { |post| post.weight }.should == weights
    end
    
    describe "respace by 10" do
      before do
        @algorithm.reweight(@post_weights, 10) 
        BlogPost.all.each { |post| @post_weights.save(post) }
      end
      
      it "should space them out more" do
        weights = []
        val = 1
        10.times do
          weights.push(val)
          val += 10 # min_spacing
        end
        
        @post_weights.new_weight.values.sort.should be == weights
        BlogPost.order(:weight).map { |post| post.weight }.should == weights
      end
    end
  end    
end
