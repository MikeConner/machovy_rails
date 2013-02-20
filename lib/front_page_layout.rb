#
# CHARTER
#   Encapsulate logic for displaying content on the front page. 
#
# USAGE 
#   Input is all current filtered content. Output is a list of content blocks with formats specified. (The blocks contain one or more object ids.)
#
# NOTES AND WARNINGS
#   Since the layout is pushed in after_transition, need an initial "start" state so that we get the first one
#
class FrontPageLayout
  attr_accessor :layout, :state
  
  BIG_DEAL_PARTIAL = 'front_grid/biglocal'
  SMALL_DEAL_PARTIAL = 'front_grid/littlelocal'
  BLOG_POST_PARTIAL = 'front_grid/blogpost'
  NON_DEAL_PARTIAL = 'front_grid/littleblocks'
  
  state_machine :state, :initial => :start do
    before_transition do
      @dice = Random.rand(100) + 1
    end
    
    after_transition any => any do |layout, transition|
      layout.display
    end
    
    state :start do
    end
    
    state :finished do
    end
    
    state :big_deal do
      def display
        if deals_available?
          layout.push({:partial => BIG_DEAL_PARTIAL, :content => @deals[@deal_idx].id})
          @deal_idx += 1
        end
      end
    end    
    
    state :small_deal do
      def display
        # Should always be deals available because of external loop, but check anyway
        if deals_available?
          layout.push({:partial => SMALL_DEAL_PARTIAL, :content => @deals[@deal_idx].id})
          @deal_idx += 1
        end
      end
    end
    
    state :blog_post do
      def display
        if blog_posts_available?
          layout.push({:partial => BLOG_POST_PARTIAL, :content => @blog_posts[@blog_post_idx].id})
          @blog_post_idx += 1
        end
      end
    end
    
    state :non_deal do
      def display
        if non_deals_available?
          layout.push({:partial => NON_DEAL_PARTIAL, :content => [@non_deals[@non_deal_idx].id, @non_deals[@non_deal_idx + 1].id]})
          @non_deal_idx += 2
        end
      end
    end
    
    # We're looping through deals externally, so there are always deals available; we *could* run out of blog posts or non_deals, though
    event :next do
      transition :start => :big_deal
      transition :big_deal => :small_deal, :if => lambda { @dice <= 40 } # 40%
      transition :big_deal => :blog_post, :if => lambda { @dice <= 80 } # 40%
      transition :big_deal => :non_deal, :if => :deals_available?
      # Fall through and terminate if we're in big_deal state and there are no more deals
      # So, must guarantee we can always get to big_deal, so that it will always terminate
      # In this machine, blog_post will always eventually transition to big_deal,
      #   so as long as every state has a way to get to blog_post, it will terminate
      transition :big_deal => :finished
      
      transition :small_deal => :big_deal, :if => lambda { @dice <= 25 } # 25%
      transition :small_deal => same, :if => lambda { @dice <= 50 } # 25%
      transition :small_deal => :blog_post, :if => lambda { @dice <= 75 } # 25%
      transition :small_deal => :non_deal
      
      transition :blog_post => :small_deal, :if => lambda { @dice <= 40 } # 40%
      transition :blog_post => :non_deal, :if => lambda { @dice <= 80 } # 40%
      transition :blog_post => :big_deal
      
      transition :non_deal => :big_deal, :if => lambda { @dice <= 40 } # 40%
      transition :non_deal => :small_deal, :if => lambda { @dice <= 80 } # 40%
      transition :non_deal => :blog_post
    end   
  end
  
  def done?
    'finished' == self.state
  end
  
  def initialize(deals, non_deals, blog_posts)
    @deals = deals
    @non_deals = non_deals
    @blog_posts = blog_posts
    @deal_idx = 0
    @non_deal_idx = 0
    @blog_post_idx = 0
    @layout = []
    super()
  end
  
  def deals_available?
    @deal_idx < @deals.length
  end
  
  def blog_posts_available?
    @blog_post_idx < @blog_posts.length
  end

  # Blocks of two, so we need to have two available
  def non_deals_available?
    @non_deal_idx < @non_deals.length - 1
  end
end