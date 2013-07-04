namespace :db do
  desc "Mix after hours in with other promotions"
  task :mixin_after_hours => :environment do
    # Remove exclusivity from After Hours and make it inactive
    # Find all After Hours promotions, add NightLife category
    ah_cat = Category.find_by_name('After Hours')
    ah_cat.toggle!(:exclusive)
    ah_cat.toggle!(:active)
    nl_cat = Category.find_by_name('NightLife')
    Promotion.select { |p| p.category_ids.include?(ah_cat.id) }.each do |ae_promotion|
      ae_promotion.categories << nl_cat
    end
  end
end