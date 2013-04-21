require 'groupon'

namespace :db do
  desc "Test Groupon Filtering"
  task :groupon_filter => :environment do
    g = Groupon.instance
    g.link_array.each do |link|
      puts "#{link['id']}: #{link['announcementTitle']}"
      puts "    #{link['tags']} -> #{g.categorize(link)}"
    end
  end
end