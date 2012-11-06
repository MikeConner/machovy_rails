require 'weighting_factory'

namespace :db do
  desc "Reweight blogs and promotions"
  task :reweight => :environment do
    algorithm = WeightingFactory.instance.create_weighting_algorithm
  
    blog_weights = WeightingFactory.instance.create_weight_data(BlogPost.name)
    BlogPost.all.each { |post| blog_weights.add(post) }    
    algorithm.reweight(blog_weights)
    BlogPost.all.each { |post| blog_weights.save(post) }
    
    promotion_weights = WeightingFactory.instance.create_weight_data(Promotion.name)
    Promotion.all.each { |promotion| promotion_weights.add(promotion) }
    algorithm.reweight(promotion_weights)
    Promotion.all.each { |promotion| promotion_weights.save(promotion) }
  end
end
