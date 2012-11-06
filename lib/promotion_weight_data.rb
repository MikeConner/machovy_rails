# CHARTER
#   Class to extract data relevant to weighting algorithms from promotions
#
# USAGE
#
# NOTES AND WARNINGS
#
class PromotionWeightData < AbstractWeightData
  def add(obj)
    super
    if !obj.is_a? Promotion
      raise "Wrong object type (expecting Promotion, got #{obj.class.name})"
    end    
    @current_weight[obj.id] = obj.grid_weight
    
    @data[obj.id][POPULARITY] = Hash.new
    # Get the whole spectrum; algorithms may want to look at the data over time; don't hard-code anything here
    # Return a hash of day -> count for that day
    Activity.where("activity_name='Promotion' and activity_id=#{obj.id}").each do |activity|
      day = activity.created_at.beginning_of_day
      if @data[obj.id][POPULARITY].has_key?(day)
        @data[obj.id][POPULARITY][day] += 1
      else
        @data[obj.id][POPULARITY][day] = 1
      end
    end
    # Urgency is days before expiration, lower numbers are "better"
    if !obj.end_date.nil? and !obj.expired?
      @data[obj.id][URGENCY] = ((obj.end_date - Time.now)/3600/24).round
    end
    
    # Value of blog posts can be measured by the associated promotions
    @data[obj.id][VALUE] = obj.expected_revenue
  end
  
protected
  def save_internal(obj)
    if !obj.update_attributes(:grid_weight => @new_weight[obj.id])
      raise "Update of Promotion(#{obj.id}) to #{@new_weight[obj.id]} failed"
    end
  end
end