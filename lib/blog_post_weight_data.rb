# CHARTER
#   Class to extract data relevant to weighting algorithms from blog posts
#
# USAGE
#
# NOTES AND WARNINGS
#
class BlogPostWeightData < AbstractWeightData
  def add(obj)
    super
    if !obj.is_a? BlogPost
      raise "Wrong object type (expecting BlogPost, got #{obj.class.name})"
    end    
    @current_weight[obj.id] = obj.weight
    
    @data[obj.id][POPULARITY] = Hash.new
    # Get the whole spectrum; algorithms may want to look at the data over time; don't hard-code anything here
    # Return a hash of day -> count for that day
    Activity.where("activity_name='BlogPost' and activity_id=#{obj.id}").each do |activity|
      day = activity.created_at.beginning_of_day
      if @data[obj.id][POPULARITY].has_key?(day)
        @data[obj.id][POPULARITY][day] += 1
      else
        @data[obj.id][POPULARITY][day] = 1
      end
    end
    # No urgency for blog posts
    # Value of blog posts can be measured by the associated promotions
    @data[obj.id][VALUE] = 0
    obj.promotions.each do |promotion|
      @data[obj.id][VALUE] += promotion.expected_revenue
    end
  end
  
protected
  def save_internal(obj)
    if !obj.update_attributes(:weight => @new_weight[obj.id])
      raise "Update of BlogPost(#{obj.id}) to #{@new_weight[obj.id]} failed"
    end
  end
end