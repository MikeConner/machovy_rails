class FixedFrontPageLayout
  attr_accessor :layout
  
  BIG_DEAL_PARTIAL = 'front_grid/biglocal'
  SMALL_DEAL_PARTIAL = 'front_grid/littlelocal'
  BLOG_POST_PARTIAL = 'front_grid/blogpost'
  NON_DEAL_PARTIAL = 'front_grid/littleblocks'
  
  # Minimum pixels for each column layout
  FIVE_COLUMN = 1200
  FOUR_COLUMN = 960
  THREE_COLUMN = 720
  
  PATTERNS = { 5 => [[BIG_DEAL_PARTIAL, SMALL_DEAL_PARTIAL, BLOG_POST_PARTIAL, NON_DEAL_PARTIAL], 
                     [BIG_DEAL_PARTIAL, BLOG_POST_PARTIAL, SMALL_DEAL_PARTIAL, SMALL_DEAL_PARTIAL]],
               4 => [[BIG_DEAL_PARTIAL, SMALL_DEAL_PARTIAL, BLOG_POST_PARTIAL, NON_DEAL_PARTIAL]],
               3 => [],
               2 => [[], [], []] }

  def initialize(deals, non_deals, blog_posts, width)
    @deals = deals
    @non_deals = non_deals
    @blog_posts = blog_posts
    @deal_idx = 0
    @non_deal_idx = 0
    @blog_post_idx = 0
    @layout = []
    @num_columns = compute_num_columns(width)
    @deals_remaining = true
    @last_pattern = -1
    
    while @deals_remaining do
      # Get a randomly selected pattern array of the appropriate column configuration
      p = PATTERNS[@num_columns][next_pattern]
      
      p.each do |partial|
        case partial
          when BIG_DEAL_PARTIAL
            layout.push({:partial => partial, :content => @deals[next_deal].id})
          when SMALL_DEAL_PARTIAL
            layout.push({:partial => partial, :content => @deals[next_deal].id})
          when BLOG_POST_PARTIAL
            layout.push({:partial => partial, :content => @blog_posts[next_blog_post].id})
          when NON_DEAL_PARTIAL
            layout.push({:partial => partial, :content => [@non_deals[next_non_deal].id, @non_deals[next_non_deal].id]})
          else
            raise 'Unknown partial'
          end
      end
      
      # Terminate if we're exactly at the end
      $deals_remaining = false if @deals.length == @deal_idx
    end
  end
  
private
  # Ensure we don't pick the same pattern twice -- unless there's only one
  def next_pattern
    loop do
      @idx = Random.rand(PATTERNS[@num_columns].length)    
      if (-1 == @last_pattern) or (@idx != @last_pattern) or (1 == PATTERNS[@num_columns].length)
        @last_pattern = @idx
        break
      end 
    end
    
    @idx
  end
  
  # Wrap around if we run out; if we wrap, it means we're at the
  def next_deal
    if @deal_idx < @deals.length
      result = @deal_idx
      @deal_idx += 1
    else
      result = 0
      @deal_idx = 1
      @deals_remaining = false
    end
    
    result  
  end
    
  def next_blog_post
    if @blog_post_idx < @blog_posts.length
      result = @blog_post_idx
      @blog_post_idx += 1
    else
      result = 0
      @blog_post_idx = 1
    end
    
    result  
  end
    
  def next_non_deal
    if @non_deal_idx < @non_deals.length
      result = @non_deal_idx
      @non_deal_idx += 1
    else
      result = 0
      @non_deal_idx = 1
    end
    
    result  
  end
    
  def compute_num_columns(width)
    if width.to_i >= FIVE_COLUMN
      5
    elsif width.to_i >= FOUR_COLUMN
      4
    elsif width.to_i >= THREE_COLUMN
      3
    else
      2
    end
  end
end