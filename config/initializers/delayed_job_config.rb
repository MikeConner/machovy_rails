# config/initializers/delayed_job_config.rb
Delayed::Worker.delay_jobs = !Rails.env.test?
