FactoryGirl.define do
  sequence(:random_url) { |n| "http://www." + Faker::Internet.domain_name }
  sequence(:random_phone) { |n| Faker::PhoneNumber.phone_number }
  sequence(:random_street) { |n| Faker::Address.street_address }
  sequence(:random_city) { |n| Faker::Address.city }
  sequence(:random_state) { |n| Faker::Address.state_abbr }
  sequence(:random_zip) { |n| Faker::Address.zip_code }
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:vendor_name) { |n| Faker::Company.name }
  sequence(:random_description) { |n| Faker::Company.catch_phrase }
  sequence(:random_comment) { |n| Faker::Lorem.sentences.join(' ') }
  sequence(:random_post) { |n| Faker::Lorem.paragraphs.join("\n") }
  sequence(:random_name) { |n| Faker::Name.name }
  
  factory :blog_post do
    curator
    metro
    
    title { generate(:random_description) }
    body { generate(:random_post) }
    weight { Random.rand(100) }
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
    twitter { generate(:random_email) } # close enough
    
    factory :curator_with_blog_posts do
      ignore do
        num_posts 6
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:blog_post, evaluator.num_posts, :curator => curator, :metro => metro)
      end
    end
    
    factory :curator_with_promotions do
      ignore do
        num_promotions 4
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:promotion, evaluator.num_promotions, :curator => curator, :metro => metro)
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
    name { generate(:vendor_name) }
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
    name { generate(:vendor_name) }
    url { generate(:random_url) }
    phone { generate(:random_phone) }
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
