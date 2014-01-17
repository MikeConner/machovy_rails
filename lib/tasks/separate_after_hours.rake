namespace :db do
  desc "Separate after hours from other promotions"
  task :separate_after_hours => :environment do
    ah_cat = Category.find_by_name(Category::ADULT)
    ah_cat.toggle!(:active)
    # Activate the After Hours category
    # Take all After Hours promotions, remove other categories, then make the category exclusive
    Promotion.select { |p| p.category_ids.include?(ah_cat.id) }.each do |ae_promotion|
      # Remove any other categories, since we're about to make it exclusive
      ae_promotion.categories = [ah_cat]
    end
    ah_cat.toggle!(:exclusive)
  end
end