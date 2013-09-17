require 'eight_coupon'

namespace :db do
  desc "Update external coupons"
  task :update_external_coupons => :environment do
    Metro.all.each do |metro|
      puts "Updating #{metro.name}"
      metro.update_external_coupons
    end
  end
end