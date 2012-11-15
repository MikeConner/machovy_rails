# CHARTER
#   Implement a particular weighting algorithm, using AbstractWeightData
#
# USAGE
#
# NOTES AND WARNINGS
#
class DefaultWeightingAlgorithm
  # Relative weights of different factors
  # Absolute values must add to 1
  # Lower values are better... so negatives here mean higher *raw* values are better
  #   Recency numbers mean "days old," so lower is better and it's positive
  VALUE_WEIGHT = -0.5
  RECENCY_WEIGHT = 0.3
  POPULARITY_WEIGHT = -0.15
  URGENCY_WEIGHT = 0.05
  POPULARITY_TIME_WINDOW = 1.week.ago
  
  # AbstractWeightData
  def reweight(weight_data, min_spacing = 5)
    # Has current_weight, new_weight (to set), and the data hash, with value, recency, popularity, and urgency values
    #current_weights = weight_data.current_weight.sort_by { |key, value| value }
    raw_weights = Hash.new
    weight_data.current_weight.map { |id, old_weight| raw_weights[id] = calculate_weight(weight_data.data[id]) }
    #puts "Raw:"
    #puts raw_weights
    
    # Here are the sorted weights
    # raw weights are calculated so that more negative is better. Add (1 - min) to all (if min < 1)
    new_weights = raw_weights.sort_by { |id, weight| weight }
    #puts "New:"
    #puts new_weights

    minimum_weight = new_weights.first[1]
    #puts "Minimum: #{minimum_weight}"
    
    if minimum_weight < 1
      offset = 1 - minimum_weight
    else 
      offset = 0
    end 
    # Now find contiguous blocks of identical weights
    # Do this by creating an inverted index of weight -> [id1, id2, id3, ...]
    #   If the inverted index for a weight has a single entry, it's unique
    #   If there are multiple indices, we have a block of items with the same weight
    inverted_idx = Hash.new
    new_weights.map do |id, weight| 
      inverted_idx[weight] ||= []
      inverted_idx[weight].push(id)
    end
    #puts "Inverted"
    #puts inverted_idx

    # update weights
    # adjusted_weights are sorted from 1..n
    # If every item has a different weight, this will simply assign the new weights
    # If there are duplicate weights (items with the same weight), we want to randomize them
    # Detect the situation by inspecting the previously calculated inverted_idx. If there are
    #   multiple entries, we've hit a block of identical weights 
    # In this case, randomize by shuffling the array of ids
    #   Since they are ordered by weight, we have to make the weights different in order to express
    #   the randomization. So add and "weight_adj" (0..n) so that each item's weight will be 1 more than
    #   its predecessor. 
    # This might result in discontinuities in the set. 
    #   For instance: 1,5,5,5,5,5,5,6,10 would become 1,5,6,7,8,9,10,6,10
    # To avoid, this we need to add an offset to all future weights, equal to the length of the contiguous run - 1
    #   We had a block of 6 5's in this example, so we'd have an offset of 5: 1,5,6,7,8,9,10,11,15
    skip = []
    #puts "Updating weights"
    new_weights.map do |id, weight|
      #puts "#{id}, #{weight}"
      next if skip.include?(id)
      
      if inverted_idx[weight].count > 1
        skip = inverted_idx[weight]
        #puts "Contiguous: #{skip}"
        weight_adj = 0
        skip.shuffle.each do |random_id|
          #puts "#{random_id} = #{weight} + #{offset} + #{weight_adj}"
          weight_data.new_weight[random_id] = weight + offset + weight_adj
          weight_adj += 1
        end
        offset += skip.count - 1
        #puts "Offset: #{offset}"
      else
        #puts "Singleton #{weight} + #{offset}"
        weight_data.new_weight[id] = weight + offset
      end
    end  
    
    #puts "Final"
    #puts weight_data.new_weight
    if !min_spacing.nil? and min_spacing > 1
      #puts "Spacing with #{min_spacing}"
      space_out(weight_data, min_spacing)
    end
  end
  
protected
  # ensure gaps of at least <spacing> in the generated weights
  def space_out(weight_data, spacing)
    last = 1
    offset = 0
    first = true
    validity = -1
    new_weights = weight_data.new_weight.sort_by { |id, weight| weight }
    new_weights.map do |id, weight|
      #puts "Spacing #{id} -> #{weight}"
      if first
        #puts "First! #{weight}"
        first = false
        last = weight
        validity = weight
        next
      end
        
      if weight <= validity
        raise 'Input must be monotonically increasing'
      else
        validity = weight
        #puts "Setting validity to #{weight}"
      end
      
      #puts "Is #{weight} + #{offset} - #{spacing} < #{last}?"
      if weight + offset - spacing < last
        #puts "YES; need to reweight"
        # not enough space
        new_weight = last + spacing
        #puts "New weight = #{last} + #{spacing}"
        weight_data.new_weight[id] = new_weight
        #puts "Add #{new_weight} - #{weight} - #{offset} to offset"
        offset += new_weight - weight - offset   
        last = new_weight
        #puts "New offset is #{offset}; last = #{last}"
      else
        #puts "NO; reset offset to 0; last = #{weight}"
        last = weight
        offset = 0
      end
    end
    
    #puts "Final"
    #puts weight_data.new_weight
  end
  
  def calculate_weight(data)
    result = 0
    if data.has_key?(AbstractWeightData::VALUE) 
      result += VALUE_WEIGHT * data[AbstractWeightData::VALUE]
    end
    
    # Recency is "inverted" higher numbers mean older, and worse, so subtract these values
    if data.has_key?(AbstractWeightData::RECENCY)
      result += RECENCY_WEIGHT * data[AbstractWeightData::RECENCY]
    end
    
    if data.has_key?(AbstractWeightData::POPULARITY)
      result += POPULARITY_WEIGHT * interpret_popularity(data[AbstractWeightData::POPULARITY])
    end
    
    if data.has_key?(AbstractWeightData::URGENCY)
      result += URGENCY_WEIGHT * data[AbstractWeightData::URGENCY]
    end
    
    result.round
  end
  
  # Convert hash of date -> count into a single number
  def interpret_popularity(popularity)
    result = 0
    popularity.map { |date, count| result += count if date >= POPULARITY_TIME_WINDOW }
    
    result
  end
end
