CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => 'AKIAJH4UCUV5IK5KXZYQ',       # required
    :aws_secret_access_key  => '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',       # required
    :region                 => 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = 'machovyimages'                     # required
#  config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
#  config.fog_public     = false                                   # optional, defaults to true
#  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  if Rails.env.test?
    config.storage = :file
#    config.enable_processing = false
  else
    config.storage = :fog
#    config.enable_processing = true
  end
end