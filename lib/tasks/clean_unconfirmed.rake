namespace :db do
  desc "Clean out old unconfirmed users"
  task :clean_unconfirmed => :environment do
    expired = User.where('confirmation_token IS NOT NULL AND created_at < ?', 6.months.ago)
    puts "Deleting #{expired.count} user(s)"
    expired.each do |user|
      user.destroy
    end
  end
end
