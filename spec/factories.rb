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
  sequence(:random_phrase) { |n| Faker::Company.catch_phrase }
  sequence(:random_sentences) { |n| Faker::Lorem.sentences.join(' ') }
  sequence(:random_paragraphs) { |n| Faker::Lorem.paragraphs.join("\n") }
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
    # Do not include Curator, or you'll break the display_name test
    activity_name { ['BlogPost', 'Order', 'Promotion', 'Video', 'Voucher'].sample }
    description { generate(:random_phrase) }
    
    factory :curator_activity do
      activity_name 'Curator'
    end
  end
  
  factory :blog_post do
    curator
    
    title { generate(:random_phrase) }
    body { generate(:random_paragraphs) }
    weight { Random.rand(100) + 1 }
    activation_date 2.days.from_now
    
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
    
    factory :blog_post_with_metro_promotions do
      ignore do
        num_metros 2
      end
      
      after(:create) do |blog_post, evaluator|
        evaluator.num_metros.times do
          metro = FactoryGirl.create(:metro_with_promotions)
          metro.reload.promotions.each do |promotion|
            blog_post.promotions << promotion
          end
        end
      end      
    end
  end
  
  factory :coupon do
    vendor
    
    title { generate(:random_phrase) }
    value { Random.rand(100) + 1 }
    description { generate(:random_paragraphs) }
    remote_coupon_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
  end
  
  factory :feedback do
    user
    order
    
    stars { Random.rand(5) + 1 }
    comments { generate(:random_paragraphs) }
    
    after(:build) do |feedback|
      feedback.recommend = Random.rand >= 0.1
    end
  end
  
  factory :idea do
    user
    
    name { generate(:random_name)[0, Idea::MAX_NAME_LEN] }
    title { generate(:random_phrase)[0, Idea::MAX_TITLE_LEN] }
    content { generate(:random_paragraphs) }
    
    factory :idea_with_ratings do
      ignore do
        num_ratings 5
      end
      
      after(:create) do |idea, evaluator|
        # Can't rate your own idea, so need to create another user
        evaluator.num_ratings.times do
          FactoryGirl.create(:rating_with_comment, :user => FactoryGirl.create(:user), :idea => idea)
        end
      end
    end
  end
  
  factory :rating do
    idea
    user
    
    stars { Random.rand(5) + 1 }
    
    factory :rating_with_comment do
      comment { generate(:random_paragraphs) }
    end
  end
  
  factory :position do
    title { generate(:random_phrase) }
    description { generate(:random_paragraphs) }
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
    
    factory :exclusive_category do
      exclusive true
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
        FactoryGirl.create_list(:category, evaluator.num_children, :parent_category_id => parent.id)
      end
    end
  end
  
  factory :curator do
    bio { generate(:random_paragraphs) }
    name { generate(:random_name) }
    twitter { generate(:random_twitter) }
    title "Style Editor"
    
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

    factory :curator_with_videos do
      ignore do
        num_videos 5
      end
      
      after(:create) do |curator, evaluator|
        FactoryGirl.create_list(:video, evaluator.num_videos, :curator => curator)
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
    amount { (Random.rand * 100).round(2) }
    description { generate(:random_phrase) }
    transaction_id '838284838203840'
    fine_print { generate(:random_sentences) }
    
    factory :order_with_address do
      name { generate(:random_name) }
      address_1 { generate(:random_street) }
      city { generate(:random_city) }
      state { generate(:random_state) }
      zipcode { generate(:random_zip) }
    end
    
    factory :order_with_name do
      name { generate(:random_name) }
      pickup_notes { generate(:random_phrase) }
    end
    
    factory :order_with_address_and_voucher do
      name { generate(:random_name) }
      address_1 { generate(:random_street) }
      city { generate(:random_city) }
      state { generate(:random_state) }
      zipcode { generate(:random_zip) }
      
      # Create redeemed; this is for a product promotion
      after(:create) do |order|
        FactoryGirl.create(:voucher, :order => order, :user => order.user, :promotion => order.promotion, :status => Voucher::REDEEMED)
      end
    end
    
    factory :order_with_vouchers do
      ignore do
        num_vouchers 3
      end
      
      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:voucher, evaluator.num_vouchers, :order => order, :user => order.user, :promotion => order.promotion)
      end
    end    
    
    factory :order_with_delayed_vouchers do
      ignore do
        num_vouchers 3
      end
      
      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:voucher, evaluator.num_vouchers, :order => order, :user => order.user, :promotion => order.promotion, :delay_hours => 6)
      end
    end    
  end
  
  factory :payment do
    vendor
    
    amount { Random.rand * 100.0 }
    check_number { Random.rand(9000) + 100 }
    check_date Time.zone.now.beginning_of_day

    factory :payment_with_notes do
      notes { generate(:random_paragraphs) }
    end
  end
    
  factory :ad, :class => Promotion do
    metro
    vendor
    
    promotion_type Promotion::AD
    status Promotion::MACHOVY_APPROVED
    title { generate(:random_phrase) }
    grid_weight { Random.rand(100) + 1 }
    destination { generate(:random_url) }
    start_date Time.zone.now
    end_date 2.weeks.from_now
    remote_teaser_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
    min_per_customer 1
    max_per_customer Promotion::UNLIMITED
  end
  
  factory :affiliate, :class => Promotion do
    metro
    vendor
    
    promotion_type Promotion::AFFILIATE
    status Promotion::MACHOVY_APPROVED
    title { generate(:random_phrase) }
    grid_weight { Random.rand(100) + 1 }
    destination { generate(:random_url) }
    start_date Time.zone.now
    end_date 2.weeks.from_now
    remote_teaser_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
    min_per_customer 1
    max_per_customer Promotion::UNLIMITED
  end
  
  factory :promotion do
    metro
    vendor
    
    promotion_type Promotion::LOCAL_DEAL
    status Promotion::PROPOSED
    title { generate(:random_phrase) }
    grid_weight { Random.rand(100) + 1 }
    retail_value { Random.rand * 1000 }
    price { Random.rand * 500 }
    revenue_shared { Random.rand }
    quantity { Random.rand(10) + 1 }
    description { generate(:random_sentences) }
    start_date Time.zone.now.beginning_of_day
    end_date 2.weeks.from_now.beginning_of_day
    remote_teaser_image_url 'http://g-ecx.images-amazon.com/images/G/01/kindle/dp/2012/famStripe/FS-KJW-125._V387998894_.gif'
    min_per_customer 1
    max_per_customer Promotion::UNLIMITED
    strategy { FactoryGirl.create(:strategy) }
    
    factory :approved_promotion do
      status Promotion::MACHOVY_APPROVED
      quantity 100
      
      factory :approved_promotion_with_delay do
        strategy { FactoryGirl.create(:strategy, :delay_hours => 6) }     
        
        factory :promotion_with_delay_and_vouchers do   
          ignore do
            num_orders 5
          end
          
          after(:create) do |promotion, evaluator|
            FactoryGirl.create_list(:order_with_delayed_vouchers, evaluator.num_orders, :amount => promotion.price, :promotion => promotion)
          end
        end
      end
    end
    
    factory :product_promotion do
      strategy { FactoryGirl.create(:product_strategy_delivery) }      
      
      factory :product_promotion_with_order do
        status Promotion::MACHOVY_APPROVED
        
        after(:create) do |promotion|
          FactoryGirl.create(:order_with_address, :amount => promotion.price, :promotion => promotion)
        end
      end
      
      factory :product_promotion_with_voucher do
        status Promotion::MACHOVY_APPROVED
        
        after(:create) do |promotion|
          FactoryGirl.create(:order_with_address_and_voucher, :amount => promotion.price, :promotion => promotion)
        end
      end
    end

    factory :product_pickup_promotion do
      status Promotion::MACHOVY_APPROVED
        
      strategy { FactoryGirl.create(:product_strategy_pickup) }      
      
      factory :product_pickup_promotion_with_order do
        after(:create) do |promotion|
          FactoryGirl.create(:order_with_name, :amount => promotion.price, :promotion => promotion)
        end
      end
    end
    
    factory :promotion_with_subtitle do
      subtitle { generate(:random_phrase) }
    end
    
    factory :promotion_with_venue_address do
      venue_address { generate(:random_street) }
      venue_city { generate(:random_city) }
      venue_state { generate(:random_state) }
      venue_zipcode { generate(:random_zip) }
      
      factory :promotion_with_map do
        latitude 40.552285
        longitude { -80.029079 }
      end
    end
        
    factory :promotion_with_orders do
      ignore do
        num_orders 5
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:order, evaluator.num_orders, :amount => promotion.price, :promotion => promotion)
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
    
    factory :promotion_with_feedback do
      ignore do
        num_orders 5
      end
      
      after(:create) do |promotion, evaluator|
        FactoryGirl.create_list(:order, evaluator.num_orders, :promotion => promotion)
        
        promotion.reload.orders.each do |order|
          order.user.feedbacks << FactoryGirl.create(:feedback, :user => order.user, :order => order)
        end
      end      
    end
  end
  
  factory :promotion_image do
    promotion
    
    caption { generate(:random_phrase) }
    remote_slideshow_image_url 'http://ecx.images-amazon.com/images/I/21kMsAPQeZL.jpg'
  end
  
  factory :promotion_log do
    promotion
    
    status { generate(:random_promotion_status) }
    
    after(:build) do |log|
      if Random.rand >= 0.2
        log.comment = generate(:random_paragraphs)
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
    confirmed_at 1.week.ago
    total_macho_bucks 0
    
    factory :super_admin_user do
      after(:create) do |user, evaluator|
        user.roles << Role.find_by_name(Role::SUPER_ADMIN)
      end
    end

    factory :content_admin_user do
      after(:create) do |user, evaluator|
        user.roles << Role.find_by_name(Role::CONTENT_ADMIN)
      end
    end

    factory :merchant_user do
      after(:create) do |user, evaluator|
        user.vendor = FactoryGirl.create(:vendor)
        user.roles << Role.find_by_name(Role::MERCHANT)
      end
    end

    # Doesn't really make sense; just testing multiple roles
    factory :power_user do
      after(:create) do |user, evaluator|
        user.roles << Role.find_by_name(Role::SUPER_ADMIN)
        user.roles << Role.find_by_name(Role::CONTENT_ADMIN)
        user.roles << Role.find_by_name(Role::SALES_ADMIN)
        user.roles << Role.find_by_name(Role::MERCHANT)
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
    
    factory :user_with_feedback do
      ignore do
        num_orders 3
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:order, evaluator.num_orders, :user => user)
        
        user.reload.orders.each do |order|
          user.feedbacks << FactoryGirl.create(:feedback, :user => user, :order => order)
        end
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
    
    factory :user_with_activities do
      ignore do
        num_activities 5
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:activity, evaluator.num_activities, :user => user)
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
    
    factory :vendor_with_vouchers do
      ignore do
        num_promotions 5
      end
      
      after(:create) do |vendor, evaluator|
        FactoryGirl.create_list(:promotion_with_vouchers, evaluator.num_promotions, :vendor => vendor)
      end
    end
    
    factory :vendor_with_map do
      latitude 40.552285
      longitude { -80.029079 }
    end
    
    factory :vendor_with_coupons do
      ignore do
        num_coupons 2
      end
      
      after(:create) do |vendor, evaluator|
        FactoryGirl.create_list(:coupon, evaluator.num_coupons, :vendor => vendor)
      end
    end
  end
    
  factory :video do
    curator
    
    destination_url { generate(:random_url) }
    title { generate(:sequential_description) }
    caption { generate(:random_sentences) }
    
    factory :you_tube_video do
      destination_url Video::YOU_TUBE_REFERENCE
      source { Video::YOU_TUBE }
    end
  end
  
  factory :voucher do
    order
    
    expiration_date 1.year.from_now
    valid_date 1.week.ago
    redemption_date 1.week.from_now
    status Voucher::AVAILABLE
    uuid { generate(:sequential_uuid) }
    notes { generate(:random_sentences) }
  end   
  
  factory :strategy, :class => FixedExpirationStrategy do
    end_date 3.months.from_now
  end

  factory :product_strategy_delivery, :class => ProductStrategy do
    sku "sku-43234"
  end

  factory :product_strategy_pickup, :class => ProductStrategy do
    delivery false
    sku "sku-15902"
  end
  
  factory :fixed_expiration_strategy do
    end_date 1.month.from_now
    
    factory :fixed_expiration_strategy_with_delay do
      delay_hours 6
    end
    
    after(:create) do |strategy|
      FactoryGirl.create(:promotion, :strategy => strategy)
    end
  end
  
  factory :relative_expiration_strategy do
    period_days 30
    
    factory :relative_expiration_strategy_with_delay do
      delay_hours 6
    end
    
    after(:create) do |strategy|
      FactoryGirl.create(:promotion, :strategy => strategy)
    end
  end
  
  factory :macho_buck do
    user
    
    amount { ((Random.rand * 50) + 1).round(2) }
    notes { generate(:random_paragraphs) }
    
    factory :macho_bucks_from_voucher do
      voucher
    end
    
    factory :macho_bucks_from_order do
      order
    end
    
    factory :macho_bucks_from_admin do
      after(:create) do |buck|
        buck.admin_id = FactoryGirl.create(:super_admin_user).id
      end
    end
    
    # Invalid case
    factory :macho_bucks_from_nonadmin do
      after(:create) do |buck|
        buck.admin_id = FactoryGirl.create(:user).id
      end
    end
  end
  
  factory :gift_certificate do
    user
    
    amount { (Random.rand(10) + 1) * 10 }
    transaction_id '838284838203840'
    email { generate(:random_email) }
    pending true
    
    factory :redeemed_gift_certificate do
      pending false
    end
  end
end

