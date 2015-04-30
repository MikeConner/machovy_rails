source 'https://rubygems.org'

gem 'rails', '3.2.20'
ruby '2.1.5'

gem 'pg', '0.17.1'
gem 'taps', '0.3.24'
gem "ckeditor", "4.1.0"

gem 'activemerchant', '1.29.3'
gem 'geocoder', '1.1.8'
gem 'nokogiri', '1.6.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '2.5.3'
  gem 'zurb-foundation', '4.0.9'
  gem 'sassy-buttons', '0.1.4'
  gem 'compass-rails', '1.0.3' #'2.0.0'
  gem 'sass-rails', '3.2.5'
end

gem 'haml', '4.0.5'
gem 'haml-rails', '0.4'

gem 'jquery-rails', '2.2.2' 
#gem 'jquery-ui-rails', '3.0.1'
# Move this into dev/test when deploying unicorn
gem 'thin', '1.6.2'

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'faker', '1.4.2'
  gem 'spork', '0.9.2'
end

group :production do
  gem 'rails_12factor', '0.0.3'
end

group :development do
  gem 'annotate', '2.6.5'
  gem "better_errors", '2.1.1'
  gem "binding_of_caller", '0.7.2'
end

group :test do
  gem 'capybara', '2.4.4' 
  gem 'capybara-webkit', '1.0.0'# '0.14.2'
  gem 'selenium-webdriver', '2.33.0'#'2.32.1'
  gem 'launchy', '2.4.2'
  gem 'database_cleaner', '1.3.0'
  gem 'factory_girl_rails', '4.5.0'
  gem 'rspec-tag_matchers', '0.1.2'
  gem 'rack-test', '0.6.2'
end

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

#for QR Codes
gem 'rqrcode-rails3', '0.1.5'

# For Authentication
gem 'devise', '2.2.8'
gem 'devise-async', '0.7.0'
gem 'cancan', '1.6.10'
gem 'omniauth-facebook', '1.4.1'

# for Admin pages
gem 'rails_admin', '0.4.8'

# for images on s3
gem 'carrierwave', '0.10.0'
gem 'fog', '1.22.1'
#for heroku, have to use this to get to imagemagick
gem 'rmagick', '2.13.4', :require => false
gem 'mini_magick', '4.0.0'

#for Human Readable URLs -> multiple objects (promo / voucher)
gem 'friendly_id', '4.0.9'

gem 'will_paginate', '3.0.5'
gem 'bootstrap-will_paginate', '0.0.10'

gem 'gibbon', '1.0.4'

gem 'delayed_job_active_record', '4.0.2'
gem 'newrelic_rpm', '3.9.6.257'
gem "state_machine", "~> 1.1.2"
gem 'carrierwave_backgrounder', '0.4.1'
