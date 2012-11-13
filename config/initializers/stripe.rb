if Rails.env.production?
  Stripe.api_key = ENV['STRIPE_SECRET_LIVE']
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_LIVE']
else
  Stripe.api_key = ENV['STRIPE_SECRET_TEST']
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_TEST']
end
