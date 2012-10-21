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
    until ApplicationHelper::US_STATES.member?(st)
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
  sequence(:random_promotion_status) { |n| Promotion::PROMOTION_STATUS.sample }
  
  # Repeatable sequences
  sequence(:sequential_url) { |n| "http://www.microsoft-#{n}.com" }
  sequence(:seqential_phone) { |n| '(412) 400-' + sprintf("%04d", n) }
  sequence(:sequential_street) { |n| "#{n} Maple Ave." }
  sequence(:sequential_city) { |n| "City #{n}" }
  sequence(:sequential_state) { |n| ApplicationHelper::US_STATES[n % VendorsHellper::US_STATES.count] }
  sequence(:sequential_zip) { |n| sprintf("%05d", n) }
  sequence(:sequential_email) { |n| "bro#{n}@macho.com" }
  sequence(:sequential_vendor_name) { |n| "Vendor #{n}" }
  sequence(:sequential_description) { |n| "Description #{n}" }
  sequence(:sequential_comment) { |n| "Comment #{n}. This is sentence 1. Here's another sentence. And this is the last sentence" }
  sequence(:sequential_post) { |n| "This is a sentence in post #{n}\n"*3 }
  sequence(:sequential_name) { |n| "Name #{n}" }
  sequence(:sequential_uuid) { |n| '2fe-cda-' + sprintf("%04d", n) }
  
  factory :activity do
    user
    
    activity_id { Random.rand(100) + 1 }
    activity_name { ['BlogPost', 'Order', 'Promotion', 'Video', 'Voucher'].sample }
    description { generate(:random_description) }
  end
  
  factory :blog_post do
    curator
    
    title { generate(:random_description) }
    body { generate(:random_post) }
    weight { Random.rand(100) + 1 }
    posted_at 1.hour.ago
    
    factory :blog_post_with_promotions do
      ignore do
        num_promotions 5
      end
      
      after(:create) do |blog_post, evaluator|
        evaluator.num_promotions.times do
          blog_post.promotions << FactoryGirl.create(:promotion)
        end
      end
    end
  end
  
  factory :position do
    title { generate(:random_description) }
    description { generate(:random_post) }
    expiration 6.months.from_now
    email_contact "careers@machovy.com"
    email_subject { title }
  end
  
  factory :category do
    # Can't do this because it causes issues with the hierarchical factory
    #name ['Cars', 'Adventure', 'Wine', 'Women', 'Song'].sample
    name { generate(:sequential_name) }
    active true
    
    factory :inactive_category do
      active false
    end
    
    factory :category_with_promotions do
      ignore do
        num_promotions 5
      end
      
      after(:create) do |category, evaluator|
        evaluator.num_promotions.times do
          category.promotions << FactoryGirl.create(:promotion)
        end
      end
    end
    
    factory :hierarchical_category do
      ignore do
        num_children 3
      end
      
      after(:create) do |parent, evaluator|
        FactoryGirl.create_list(:category, evaluator.num_children, :category => parent)
      end
    end
  end
  
  factory :curator do
    bio { generate(:random_post) }
    name { generate(:random_name) }
    twitter { generate(:random_twitter) }
    
    factory :curator_with_blog_posts do
      ignore do
        num_posts 6
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:blog_post, evaluator.num_posts, :curator => curator)
      end
    end
    
    factory :curator_with_promotions do
      ignore do
        num_posts_with_promotions 4
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:blog_post_with_promotions, evaluator.num_posts_with_promotions, :curator => curator)
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
    charge_id "ch_0aCv7NedlDjXia"
    
    factory :order_with_vouchers do
      ignore do
        num_vouchers 3
      end
      
      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:voucher, evaluator.num_vouchers, :order => order, :user => order.user, :promotion => order.promotion)
      end
    end
  end
  
  factory :ad, :class => Promotion do
    metro
    vendor
    
    promotion_type Promotion::AD
    status Promotion::MACHOVY_APPROVED
    title { generate(:random_description) }
    grid_weight { Random.rand(100) + 1 }
    destination { generate(:random_url) }
    start_date Time.now
    end_date 2.weeks.from_now
    remote_main_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
  end
  
  factory :affiliate, :class => Promotion do
    metro
    vendor
    
    promotion_type Promotion::AFFILIATE
    status Promotion::MACHOVY_APPROVED
    title { generate(:random_description) }
    grid_weight { Random.rand(100) + 1 }
    destination { generate(:random_url) }
    start_date Time.now
    end_date 2.weeks.from_now
    remote_main_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
  end
  
  factory :promotion do
    metro
    vendor
    
    promotion_type Promotion::LOCAL_DEAL
    status Promotion::PROPOSED
    title { generate(:random_description) }
    grid_weight { Random.rand(100) + 1 }
    retail_value { Random.rand * 1000 }
    price { Random.rand * 500 }
    revenue_shared { Random.rand }
    quantity { Random.rand(10) + 1 }
    description { generate(:random_comment) }
    start_date Time.now
    end_date 2.weeks.from_now
    remote_main_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
        
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
    
    factory :promotion_with_categories do
      ignore do
        num_categories 5
      end

      after(:create) do |promotion, evaluator|
        evaluator.num_categories.times do
          promotion.categories << FactoryGirl.create(:category)
        end
      end
    end
    
    factory :promotion_with_blog_posts do
      ignore do
        num_posts 5
      end

      after(:create) do |promotion, evaluator|
        evaluator.num_posts.times do
          promotion.blog_posts << FactoryGirl.create(:blog_post)
        end
      end
    end
    
    factory :promotion_with_logs do
      ignore do
        num_logs 5
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:promotion_log, evaluator.num_logs, :promotion => promotion)
      end
    end
    
    factory :promotion_with_images do
      ignore do
        num_images 3
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:promotion_image, evaluator.num_images, :promotion => promotion)
      end
    end
  end
  
  factory :promotion_image do
    promotion
    
    caption { generate(:random_description) }
    media_type { PromotionImage::SUPPORTED_MEDIA_TYPES.sample }
    remote_image_url 'http://ecx.images-amazon.com/images/I/21kMsAPQeZL.jpg'
  end
  
  factory :promotion_log do
    promotion
    
    status { generate(:random_promotion_status) }
    
    after(:build) do |log|
      if Random.rand >= 0.2
        log.comment = generate(:random_post)
      end
    end
  end
  
  factory :role do
    name { [Role::SUPER_ADMIN, Role::CONTENT_ADMIN, Role::MERCHANT].sample }
    
    factory :role_with_users do
      ignore do
        num_users 5
      end
      
      after(:create) do |role, evaluator|
        evaluator.num_users.times do
          role.users << FactoryGirl.create(:user)
        end
      end
    end
  end

  # Aliases aren't working???
  factory :user, :aliases => [:administrator, :merchant, :dude] do
    email { generate(:random_email) }
    password "Password"
    password_confirmation "Password"
    
    factory :super_admin_user do
      after(:create) do |user, evaluator|
        user.roles.create(:name => Role::SUPER_ADMIN)
      end
    end

    factory :content_admin_user do
      after(:create) do |user, evaluator|
        user.roles.create(:name => Role::CONTENT_ADMIN)
      end
    end

    factory :merchant_user do
      after(:create) do |user, evaluator|
        user.roles.create(:name => Role::MERCHANT)
      end
    end

    # Doesn't really make sense; just testing multiple roles
    factory :power_user do
      after(:create) do |user, evaluator|
        user.roles.create(:name => Role::SUPER_ADMIN)
        user.roles.create(:name => Role::CONTENT_ADMIN)
        user.roles.create(:name => Role::MERCHANT)
      end
    end
    
    factory :user_with_orders do
      ignore do
        num_orders 3
      end
            
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:order, evaluator.num_orders, :user => user)
      end
    end
    
    factory :user_with_vouchers do
      ignore do
        num_orders 3
      end
            
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:order_with_vouchers, evaluator.num_orders, :user => user)
      end
    end
  end
  
  factory :vendor do   
    user
    
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
    
    factory :vendor_with_promotions do
      ignore do
        num_promotions 5
      end
      
      after(:create) do |vendor, evaluator|
        FactoryGirl.create_list(:promotion, evaluator.num_promotions, :vendor => vendor)        
      end
    end
    
    factory :vendor_with_orders do
      ignore do
        num_promotions 5
      end
      
      after(:create) do |vendor, evaluator|
        FactoryGirl.create_list(:promotion_with_orders, evaluator.num_promotions, :vendor => vendor)
      end
    end
  end
    
  factory :video do
    destination_url { generate(:random_city) }
    name { generate(:random_description) }
    active true
    
    factory :inactive_video do
      active false
    end
  end
  
  factory :voucher do
    order
    
    expiration_date 1.year.from_now
    issue_date 1.week.ago
    redemption_date 1.week.from_now
    status Voucher::AVAILABLE
    uuid { generate(:sequential_uuid) }
    notes { generate(:random_comment) }
  end    
end
