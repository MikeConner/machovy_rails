require 'singleton'
require 'default_weighting_algorithm'

require 'abstract_weight_data'
require 'blog_post_weight_data'
require 'promotion_weight_data'

# CHARTER
#   Factory for weighting algorithms. Promotions have grid_weights, and blog posts have weights, which influence their presentation
# Blog posts are more sensitive, since the top 4 or so are displayed on the site all the time.
#
# USAGE
#   Pass in the class to select the data, then the algorithm used to process the weights.
#
#   create_weighting_algorithm(BlogPost.class, 'special')
#
# NOTES AND WARNINGS
#
class WeightingFactory
  include Singleton

  def create_weighting_algorithm(name = nil)
    if name.nil?
      DefaultWeightingAlgorithm.new
    else
      raise "No converter defined for #{name}"
    end
  end
  
  def create_weight_data(class_name)
    case class_name
    when BlogPost.name
      BlogPostWeightData.new
    when Promotion.name
      PromotionWeightData.new
    else
      raise "No weight data defined for #{class_obj}"
    end
  end
end


