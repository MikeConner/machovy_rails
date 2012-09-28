FactoryGirl.define do
  # There is some danger in using random data in tests -- random values are not repeatable, so data-dependent bugs might show up intermittently
  #   On the other hand, using fixed data would never find those bugs at all.
  # For the moment, I'm using random data for tests, but also have "regular" sequences available should they become necessary
  #
  # Random sequences
  sequence(:random_url) { |n| "http://www." + Faker::Internet.domain_name }
  # This generates wildly different phone numbers: 1-800-324-3242, (650) 832-3423 x34333, 123-343-3423 x52, and so on
  # TODO Need normalization to use with validators; defer for now
  sequence(:random_phone) { |n| Faker::PhoneNumber.phone_number }
  sequence(:random_street) { |n| Faker::Address.street_address }
  sequence(:random_city) { |n| Faker::Address.city }
  sequence(:random_state) do
    st = ""
    until VendorsHelper::US_STATES.member?(st)
      st = Faker::Address.state_abbr
    end
    st
  end
  sequence(:random_zip) { |n| Faker::Address.zip_code }
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:random_vendor_name) { |n| Faker::Company.name }
  sequence(:random_description) { |n| Faker::Company.catch_phrase }
  sequence(:random_comment) { |n| Faker::Lorem.sentences.join(' ') }
  sequence(:random_post) { |n| Faker::Lorem.paragraphs.join("\n") }
  sequence(:random_name) { |n| Faker::Name.name }
  # This is actually sequential; Faker doesn't support Twitter
  sequence(:random_twitter) { |n| "@Cool_Dude_#{n}" }
  
  # Repeatable sequences
  sequence(:sequential_url) { |n| "http://www.microsoft-#{n}.com" }
  sequence(:seqential_phone) { |n| '(412) 400-' + sprintf("%04d", n) }
  sequence(:sequential_street) { |n| "#{n} Maple Ave." }
  sequence(:sequential_city) { |n| "City #{n}" }
  sequence(:sequential_state) { |n| VendorsHelper::US_STATES[n % VendorsHellper::US_STATES.count] }
  sequence(:sequential_zip) { |n| sprintf("%05d", n) }
  sequence(:sequential_email) { |n| "bro#{n}@macho.com" }
  sequence(:sequential_vendor_name) { |n| "Vendor #{n}" }
  sequence(:sequential_description) { |n| "Description #{n}" }
  sequence(:sequential_comment) { |n| "Comment #{n}. This is sentence 1. Here's another sentence. And this is the last sentence" }
  sequence(:sequential_post) { |n| "This is a sentence in post #{n}\n"*3 }
  sequence(:sequential_name) { |n| "Name #{n}" }
  
  factory :blog_post do
    curator
    metro
    
    title { generate(:random_description) }
    body { generate(:random_post) }
    weight { Random.rand(100) + 1 }
    posted_at 1.hour.ago
  end
  
  factory :category do
    name ['Cars', 'Adventure', 'Wine', 'Women', 'Song'].sample
    status true
    
    factory :inactive_category do
      status false
    end
  end
  
  factory :curator do
    metro
    user
    
    bio { generate(:random_post) }
    name { generate(:random_name) }
    twitter { generate(:random_twitter) }
    
    factory :curator_with_blog_posts do
      ignore do
        num_posts 6
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:blog_post, evaluator.num_posts, :curator => curator, :metro => curator.metro)
      end
    end
    
    factory :curator_with_promotions do
      ignore do
        num_promotions 4
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:promotion, evaluator.num_promotions, :curator => curator, :metro => curator.metro)
      end
    end
  end
  
  factory :metro do
     name { generate(:random_city) }
     
     factory :metro_with_promotions do
       ignore do
         num_promotions 4
       end

       after(:create) do |metro, evaluator|
         FactoryGirl.create_list(:promotion, evaluator.num_promotions, :metro => metro)
       end
     end
   end
  
  factory :order do
    promotion
    user
    
    email { user.email }
    amount { Random.rand * 100 }
    description { generate(:random_description) }
    stripe_card_token "nva3hvao73SI&H#Nfishuefse"
    
    factory :order_with_vouchers do
      ignore do
        num_vouchers 3
      end
      
      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:voucher, evaluator.num_vouchers, :order => order, :user => user, :promotion => promotion)
      end
    end
  end
  
  factory :promotion_image do
    imageurl { generate(:random_url) }
    name { generate(:random_vendor_name) }
    mediatype { ['png', 'jpg', 'bmp'].sample }
  end

  factory :promotion do
    metro
    vendor
    curator
    
    grid_weight { Random.rand(100) + 1 }
    retail_value { Random.rand * 1000 }
    price { Random.rand * 500 }
    revenue_shared { Random.rand }
    quantity { Random.rand(10) }
    
    factory :promotion_with_orders do
      ignore do
        num_orders 5
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:order, evaluator.num_orders, :promotion => promotion)
      end
    end

    factory :promotion_with_vouchers do
      ignore do
        num_orders 5
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:order_with_vouchers, evaluator.num_orders, :promotion => promotion)
      end
    end
  end
  
  factory :role do
    name { ["SuperAdmin", "Admin", "Curator", "Merchant", "Dude"].sample }
  end

  # Aliases aren't working???
  factory :user, :aliases => [:administrator, :merchant, :dude] do
    email { generate(:random_email) }
    password "Password"
  end
  
  factory :vendor do   
    name { generate(:random_vendor_name) }
    url { generate(:random_url) }
    phone "(412) 555-1212"
    address_1 { generate(:random_street) }
    city { generate(:random_city) }
    state { generate(:random_state) }
    zip { generate(:random_zip) }
     
    after(:build) do |v|
      # Half the time, use an address_2
      if Random.rand >= 0.5
        suite = Faker::Address.street_address(:include_secondary => true)
        v.address_2 = suite.split.last(2).join(" ")
      end
    end
  end
    
  factory :video do
    active true
    destination { generate(:random_city) }
    name { generate(:random_description) }
    
    factory :inactive_video do
      active false
    end
  end
  
  factory :voucher do
    user
    order
    promotion
    
    expiration_date 1.year.from_now
    issue_date 1.week.ago
    redemption_date 1.week.from_now
    status "Good"
    uuid { SecureRandom.uuid }
    notes { generate(:random_comment) }
    
  end  
end
