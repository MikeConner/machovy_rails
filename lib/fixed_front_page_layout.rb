class FixedFrontPageLayout
  attr_accessor :layout, :page_start, :page_end, :num_columns
  
  BIG_DEAL = 'front_grid/biglocal'
  SMALL_DEAL = 'front_grid/littlelocal'
  BLOG_POST = 'front_grid/blogpost'
  NON_DEAL = 'front_grid/littleblocks'
  
  # Minimum pixels for each column layout
  FIVE_COLUMN = 1200
  FOUR_COLUMN = 960
  THREE_COLUMN = 720
  TWO_COLUMN = 470
  DESIRED_ROWS = 7
  
  # NOTE: There has to be at least one pattern in each column section that doesn't have a NON_DEAL (to avoid infinite loop)
  STARTUP_PATTERNS = { 5 => [[BIG_DEAL,BLOG_POST,NON_DEAL,BLOG_POST],
                             [NON_DEAL,BIG_DEAL,BLOG_POST,BLOG_POST],
                             [BLOG_POST,BIG_DEAL,BLOG_POST,BLOG_POST],
                             [BLOG_POST,SMALL_DEAL,BLOG_POST,NON_DEAL,BLOG_POST],
                             [BLOG_POST,SMALL_DEAL,BLOG_POST,BLOG_POST,BLOG_POST],
                             [BLOG_POST,BLOG_POST,BLOG_POST,SMALL_DEAL,BLOG_POST],
                             [BLOG_POST,NON_DEAL,BLOG_POST,BIG_DEAL]],
                       4 => [[BIG_DEAL,BLOG_POST,NON_DEAL],
                             [NON_DEAL,BIG_DEAL,BLOG_POST],
                             [BLOG_POST,BIG_DEAL,BLOG_POST],
                             [BLOG_POST,BIG_DEAL,BLOG_POST],
                             [BLOG_POST,SMALL_DEAL,BLOG_POST,NON_DEAL],
                             [BLOG_POST,SMALL_DEAL,BLOG_POST,BLOG_POST],
                             [BLOG_POST,NON_DEAL,BIG_DEAL],
                             [BLOG_POST,BLOG_POST,BIG_DEAL]],
                       3 => [[BIG_DEAL,BLOG_POST],
                             [BIG_DEAL,NON_DEAL],
                             [NON_DEAL,BIG_DEAL],
                             [BLOG_POST,SMALL_DEAL,NON_DEAL],
                             [BIG_DEAL,BLOG_POST],
                             [BLOG_POST,BIG_DEAL],
                             [BLOG_POST,SMALL_DEAL,BLOG_POST],
                             [BLOG_POST,BIG_DEAL]],
                       2 => [[BIG_DEAL], 
                             [SMALL_DEAL,BLOG_POST], 
                             [BLOG_POST,SMALL_DEAL], 
                             [SMALL_DEAL,NON_DEAL],
                             [NON_DEAL,SMALL_DEAL],
                             [BLOG_POST,NON_DEAL]],
                       1 => [[SMALL_DEAL], [BLOG_POST], [NON_DEAL]] }
                       
  PATTERNS = { 5 => [[BIG_DEAL,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,BLOG_POST,BIG_DEAL,SMALL_DEAL],
                     #[SMALL_DEAL,NON_DEAL,BLOG_POST,NON_DEAL,SMALL_DEAL],
                     #[BIG_DEAL,BLOG_POST,SMALL_DEAL,NON_DEAL],
                     [BIG_DEAL,BLOG_POST,SMALL_DEAL,BLOG_POST],
                     [SMALL_DEAL,NON_DEAL,BLOG_POST,SMALL_DEAL,SMALL_DEAL],
                     #[NON_DEAL,SMALL_DEAL,SMALL_DEAL,NON_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,BLOG_POST,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,SMALL_DEAL,NON_DEAL,SMALL_DEAL,SMALL_DEAL],
                     [BIG_DEAL,BLOG_POST,SMALL_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,SMALL_DEAL,BIG_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,BIG_DEAL,SMALL_DEAL,BLOG_POST],
                     #[SMALL_DEAL,BIG_DEAL,SMALL_DEAL,NON_DEAL],
                     #[SMALL_DEAL,BIG_DEAL,NON_DEAL,BLOG_POST],
                     [NON_DEAL,BIG_DEAL,SMALL_DEAL,SMALL_DEAL],
                     [SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,BIG_DEAL],
                     [SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,BLOG_POST,NON_DEAL],
                     [SMALL_DEAL,BLOG_POST,SMALL_DEAL,BLOG_POST,SMALL_DEAL],
                     #[SMALL_DEAL,BLOG_POST,SMALL_DEAL,NON_DEAL,SMALL_DEAL],
                     #[NON_DEAL,SMALL_DEAL,SMALL_DEAL,NON_DEAL,SMALL_DEAL],
                     #[BLOG_POST,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,NON_DEAL]],
                     [BLOG_POST,SMALL_DEAL,SMALL_DEAL,SMALL_DEAL,BLOG_POST]],
               4 => [[BIG_DEAL, SMALL_DEAL, SMALL_DEAL],
                     [SMALL_DEAL, BLOG_POST, BIG_DEAL],
                     #[SMALL_DEAL, NON_DEAL, BLOG_POST, NON_DEAL],
                     [BIG_DEAL, BLOG_POST, SMALL_DEAL],
                     #[SMALL_DEAL, NON_DEAL, NON_DEAL, SMALL_DEAL],
                     #[NON_DEAL, SMALL_DEAL, SMALL_DEAL, NON_DEAL],
                     [SMALL_DEAL, BLOG_POST, SMALL_DEAL, SMALL_DEAL],
                     #[SMALL_DEAL, NON_DEAL, SMALL_DEAL, SMALL_DEAL],
                     [BIG_DEAL, BIG_DEAL],
                     [SMALL_DEAL, SMALL_DEAL, SMALL_DEAL, SMALL_DEAL],
                     [SMALL_DEAL, SMALL_DEAL, BIG_DEAL],
                     [SMALL_DEAL, BIG_DEAL, SMALL_DEAL],
                     [SMALL_DEAL, BIG_DEAL, NON_DEAL],
                     [NON_DEAL, BIG_DEAL, SMALL_DEAL]],
               3 => [[BIG_DEAL, SMALL_DEAL], 
                     [BIG_DEAL, BLOG_POST],
                     #[BIG_DEAL, NON_DEAL],
                     [SMALL_DEAL, BIG_DEAL],
                     [SMALL_DEAL, SMALL_DEAL, SMALL_DEAL],
                     [SMALL_DEAL, SMALL_DEAL, BLOG_POST],
                     #[SMALL_DEAL, SMALL_DEAL, NON_DEAL],
                     [SMALL_DEAL, BLOG_POST, SMALL_DEAL],
                     [SMALL_DEAL, BLOG_POST, NON_DEAL],
                     [SMALL_DEAL, NON_DEAL, SMALL_DEAL],
                     #[SMALL_DEAL, NON_DEAL, BLOG_POST],
                     [BLOG_POST, BIG_DEAL],
                     [BLOG_POST, SMALL_DEAL, SMALL_DEAL],
                     [BLOG_POST, SMALL_DEAL, BLOG_POST],
                     #[BLOG_POST, SMALL_DEAL, NON_DEAL],
                     #[BLOG_POST, NON_DEAL, SMALL_DEAL],
                     [NON_DEAL, BIG_DEAL],
                     #[NON_DEAL, SMALL_DEAL, SMALL_DEAL],
                     #[NON_DEAL, SMALL_DEAL, BLOG_POST],
                     #[NON_DEAL, SMALL_DEAL, NON_DEAL],
                     [NON_DEAL, BLOG_POST, SMALL_DEAL]],
                     #[NON_DEAL, BLOG_POST, NON_DEAL],
                     #[NON_DEAL, NON_DEAL, SMALL_DEAL],
                     #[NON_DEAL, NON_DEAL, BLOG_POST]],
               2 => [[BIG_DEAL], 
                     [SMALL_DEAL, BLOG_POST], 
                     [SMALL_DEAL, NON_DEAL],
                     [SMALL_DEAL, SMALL_DEAL],
                     [NON_DEAL, BLOG_POST],
                     #[NON_DEAL, NON_DEAL],
                     #[BLOG_POST, NON_DEAL],
                     #[NON_DEAL, SMALL_DEAL],
                     [BLOG_POST, SMALL_DEAL]],
               1 => [[BIG_DEAL], [SMALL_DEAL], [SMALL_DEAL], [SMALL_DEAL], [BLOG_POST], [BLOG_POST], [NON_DEAL]] }

  def initialize(deals, non_deals, blog_posts, width)
    @deals = deals
    @non_deals = non_deals
    @blog_posts = blog_posts
    @layout = []

    # Cannot render anything if we have literally no deals
    # Have to tolerate missing "non-deals," at least for now, or categories without associated non-deals (e.g., exclusive categories)
    #   will cause an empty display
    return if @deals.empty? or @blog_posts.empty?

    @deal_idx = 0
    @non_deal_idx = 0
    @blog_post_idx = 0
    @num_columns = compute_num_columns(width)
    @page_start = { 1 => 0 }
    @page_end = Hash.new
    @deals_remaining = true
    @last_pattern = -1
    @startup_mode = @deals.count < 4
    
    page_length = 0
    row_cnt = DESIRED_ROWS
    page_idx = 1
    loop do
      # Get a randomly selected pattern array of the appropriate column configuration
      np = next_pattern(@startup_mode ? STARTUP_PATTERNS : PATTERNS)
      p = @startup_mode ? STARTUP_PATTERNS[@num_columns][np] : PATTERNS[@num_columns][np]
      
      # Have to reject patterns that contain non-deals if we don't have any!
      next if @non_deals.empty? and p.include?(NON_DEAL)
      
      page_length += @num_columns
      p.each do |partial|
        if BIG_DEAL == partial
          page_length -= 1
        end
      end
      
      row_cnt -= 1
      
      p.each do |partial|
        case partial
          when BIG_DEAL
            layout.push({:partial => partial, :content => @deals[next_deal].id})
          when SMALL_DEAL
            layout.push({:partial => partial, :content => @deals[next_deal].id})
          when BLOG_POST
            layout.push({:partial => partial, :content => @blog_posts[next_blog_post].id})
          when NON_DEAL
            layout.push({:partial => partial, :content => [@non_deals[next_non_deal].id, @non_deals[next_non_deal].id]})
          else
            raise 'Unknown partial'
          end
      end
      
      # Terminate if we're exactly at the end      
      @deals_remaining = false if @deals.length == @deal_idx
      
      if (0 == row_cnt) or !@deals_remaining
        @page_end[page_idx] = page_length - 1
        
        page_idx += 1
        if @deals_remaining
          @page_start[page_idx] = page_length
          row_cnt = DESIRED_ROWS
        else
          break
        end
      end
    end
  end
  
private
  # Ensure we don't pick the same pattern twice -- unless there's only one
  def next_pattern(pattern_template)
    loop do
      @idx = Random.rand(pattern_template[@num_columns].length)  
      if (-1 == @last_pattern) or (@idx != @last_pattern) or (1 == pattern_template[@num_columns].length)
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
    elsif width.to_i >= TWO_COLUMN
      2
    else
      1
    end
  end
end
