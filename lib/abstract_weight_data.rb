# CHARTER
#   Abstract class to define the kinds of data used in weighting algorithms. Subclassses know how to read these data
# from the relevant objects, and update the model with the new weight.
#
# USAGE
#
# NOTES AND WARNINGS
#   I know there's no such thing as an abstract class in Ruby; sorry for writing Java in Ruby :-)
# That's the intent, though. Implementations are possible but really complicated, and there's no compelling reason to
#   implement it that rigorously. The inheritance is necessary because you're manipulating different data models in
#   different weighting classes
#
class AbstractWeightData
  POPULARITY = 'Popularity' # Measure of demand for this item
  URGENCY = 'Urgency'       # Is it about to expire? Some algorithms might push things higher that are about to go away
  VALUE = 'Value'           # Estimate of the potential revenue from this item
  RECENCY = 'Recency'
  
  attr_accessor :current_weight, :new_weight, :data
  
  def initialize
    @current_weight = Hash.new
    @new_weight = Hash.new
    @data = Hash.new
  end
    
  def add(obj)
    if !obj.respond_to?(:created_at)
      raise '#{obj.class.name} is not an ActiveRecord model'
    end
    
    @data[obj.id] = Hash.new
    # time in days
    @data[obj.id][RECENCY] = ((Time.zone.now - obj.created_at)/3600/24).round
  end

  def save(obj)
    #puts "#{obj.id}: New #{@new_weight[obj.id]}; Current #{@current_weight[obj.id]}"
    if !@new_weight[obj.id].nil? and (@new_weight[obj.id] != @current_weight[obj.id])
      save_internal(obj)
    end
  end
  
protected
  def save_internal(obj)
    raise 'Unimplemented abstract method error'
  end
end