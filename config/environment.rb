# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MachovyRails::Application.initialize!

ActionMailer::Base.smtp_settings = { 
  :address => 'smtp.gmail.com', 
  :domain  => 'machovy.com',
  :port      => 587, 
  :user_name => ApplicationHelper::MAILER_FROM_ADDRESS,
  :password => ApplicationHelper::SMTP_PASSWORD, 
  :authentication => :plain,
  :enable_starttls_auto => true
} 
