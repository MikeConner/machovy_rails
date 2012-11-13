if ENV['STRIPE_SECRET'].nil?
	Stripe.api_key = "44"
	# "sk_0INin2jwTLiOY4xFw8wLZO3DWQWul"
else
	Stripe.api.key = ENV['STRIPE_SECRET']
end

if ENV['STRIPE_SECRET'].nil?
	STRIPE_PUBLIC_KEY = "pl1"
	# "pk_0INiaGmtnANOHmlgZKUD44MQ8Na41"
else
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC']
end