namespace :db do
  desc "Verify affiliate and ad links"
  task :link_check => :environment do
    puts "Checking Affiliate and Ad links..."
    Promotion.all.each do |promotion|
      if promotion.affiliate? or promotion.ad?
        if promotion.destination.nil?
          puts "Promotion {#promotion.id} (#{promotion.title}) has no destination"
        else
          uri = URI.parse(promotion.destination)
          http = Net::HTTP.new(uri.host, 80)
          request = Net::HTTP::Get.new(uri.request_uri)
          
          response = http.request(request)                 
          if ![200,301,302].include?(Integer(response.code))
            puts "#{response.code}: Promotion #{promotion.id} (#{promotion.title}) has an invalid destination: #{promotion.destination}"
          end          
        end
      end
    end
  end
end
