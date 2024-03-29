# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130917192013) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "activity_name", :limit => 32, :null => false
    t.integer  "activity_id",                 :null => false
    t.string   "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "bitcoin_invoices", :force => true do |t|
    t.integer  "order_id"
    t.decimal  "price"
    t.string   "currency",         :limit => 3, :default => "USD"
    t.string   "pos_data"
    t.string   "notification_key"
    t.string   "invoice_id"
    t.string   "invoice_url"
    t.decimal  "btc_price"
    t.datetime "invoice_time"
    t.datetime "expiration_time"
    t.datetime "current_time"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "curator_id"
    t.datetime "activation_date"
    t.integer  "weight"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "slug"
    t.string   "associated_image"
  end

  add_index "blog_posts", ["slug"], :name => "index_blog_posts_on_slug"

  create_table "blog_posts_promotions", :id => false, :force => true do |t|
    t.integer "blog_post_id", :null => false
    t.integer "promotion_id", :null => false
  end

  add_index "blog_posts_promotions", ["blog_post_id", "promotion_id"], :name => "index_blog_posts_promotions_on_blog_post_id_and_promotion_id", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name",                                  :null => false
    t.boolean  "active"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "parent_category_id"
    t.boolean  "exclusive",          :default => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "categories_external_coupons", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "external_coupon_id"
  end

  add_index "categories_external_coupons", ["category_id", "external_coupon_id"], :name => "by_category_and_coupon", :unique => true

  create_table "categories_promotions", :id => false, :force => true do |t|
    t.integer "category_id",  :null => false
    t.integer "promotion_id", :null => false
  end

  add_index "categories_promotions", ["category_id", "promotion_id"], :name => "index_categories_promotions_on_category_id_and_promotion_id", :unique => true

  create_table "categories_users", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "user_id"
  end

  add_index "categories_users", ["category_id", "user_id"], :name => "index_categories_users_on_category_id_and_user_id", :unique => true

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "coupons", :force => true do |t|
    t.string   "title",        :limit => 64
    t.integer  "value"
    t.text     "description"
    t.string   "slug"
    t.string   "coupon_image"
    t.integer  "vendor_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "curators", :force => true do |t|
    t.string   "name"
    t.string   "picture"
    t.text     "bio"
    t.string   "twitter"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "slug"
    t.string   "title",      :limit => 48
    t.integer  "weight"
  end

  add_index "curators", ["name"], :name => "index_curators_on_name", :unique => true
  add_index "curators", ["slug"], :name => "index_curators_on_slug"
  add_index "curators", ["twitter"], :name => "index_curators_on_twitter", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "external_coupons", :force => true do |t|
    t.integer  "metro_id"
    t.string   "name",                          :null => false
    t.string   "address_1"
    t.string   "address_2"
    t.string   "deal_url",                      :null => false
    t.string   "store_url"
    t.string   "source"
    t.string   "phone",           :limit => 14
    t.string   "city",            :limit => 50
    t.string   "state",           :limit => 2
    t.string   "zip",             :limit => 10
    t.integer  "deal_id",                       :null => false
    t.string   "user_name"
    t.integer  "user_id"
    t.string   "title",                         :null => false
    t.text     "disclaimer"
    t.text     "deal_info"
    t.date     "expiration_date",               :null => false
    t.datetime "post_date"
    t.string   "small_image_url",               :null => false
    t.string   "big_image_url",                 :null => false
    t.string   "logo_url"
    t.integer  "deal_type_id"
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.decimal  "distance"
    t.decimal  "original_price"
    t.decimal  "deal_price"
    t.decimal  "deal_savings"
    t.decimal  "deal_discount"
    t.string   "slug"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "external_coupons", ["deal_id"], :name => "index_external_coupons_on_deal_id", :unique => true
  add_index "external_coupons", ["slug"], :name => "index_external_coupons_on_slug"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.integer  "stars"
    t.boolean  "recommend"
    t.text     "comments"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "feedbacks", ["user_id", "order_id"], :name => "index_feedbacks_on_user_id_and_order_id", :unique => true

  create_table "fixed_expiration_strategies", :force => true do |t|
    t.datetime "end_date",                   :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "delay_hours", :default => 0, :null => false
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "gift_certificates", :force => true do |t|
    t.integer  "user_id"
    t.integer  "amount",                                         :null => false
    t.string   "email",                                          :null => false
    t.boolean  "pending",                      :default => true
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "transaction_id", :limit => 15
    t.string   "first_name",     :limit => 24
    t.string   "last_name",      :limit => 48
  end

  create_table "ideas", :force => true do |t|
    t.string   "name",       :limit => 16
    t.string   "title",      :limit => 40
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "invoice_status_updates", :force => true do |t|
    t.integer  "bitcoin_invoice_id"
    t.string   "status",             :limit => 15, :default => "new"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  create_table "ip_caches", :force => true do |t|
    t.string   "ip",         :limit => 16, :null => false
    t.decimal  "latitude",                 :null => false
    t.decimal  "longitude",                :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "ip_caches", ["ip"], :name => "index_ip_caches_on_ip", :unique => true

  create_table "macho_bucks", :force => true do |t|
    t.decimal  "amount",     :null => false
    t.text     "notes"
    t.integer  "admin_id"
    t.integer  "user_id"
    t.integer  "voucher_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "order_id"
  end

  create_table "metros", :force => true do |t|
    t.string   "name",                               :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.decimal  "latitude",   :default => 40.438169,  :null => false
    t.decimal  "longitude",  :default => -80.001875, :null => false
  end

  add_index "metros", ["name"], :name => "index_metros_on_name", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "description"
    t.string   "email"
    t.decimal  "amount"
    t.integer  "promotion_id"
    t.integer  "user_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "fine_print"
    t.integer  "quantity",                     :default => 1, :null => false
    t.string   "slug"
    t.string   "name",           :limit => 73
    t.string   "address_1",      :limit => 50
    t.string   "address_2",      :limit => 50
    t.string   "city",           :limit => 50
    t.string   "state",          :limit => 2
    t.string   "zipcode",        :limit => 10
    t.string   "transaction_id", :limit => 15
    t.string   "first_name",     :limit => 24
    t.string   "last_name",      :limit => 48
    t.string   "pickup_notes"
  end

  create_table "payments", :force => true do |t|
    t.decimal  "amount",       :null => false
    t.integer  "check_number", :null => false
    t.date     "check_date",   :null => false
    t.text     "notes"
    t.integer  "vendor_id",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "positions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "expiration"
    t.string   "email_contact"
    t.string   "email_subject"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "product_strategies", :force => true do |t|
    t.boolean  "delivery",                 :default => true
    t.string   "sku",        :limit => 48
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "promotion_images", :force => true do |t|
    t.string   "caption",                    :limit => 64
    t.string   "media_type",                 :limit => 16
    t.string   "slideshow_image"
    t.string   "remote_slideshow_image_url"
    t.integer  "promotion_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "slideshow_image_processing"
  end

  create_table "promotion_logs", :force => true do |t|
    t.integer  "promotion_id"
    t.string   "status",       :limit => 16, :null => false
    t.text     "comment"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "promotions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "limitations"
    t.text     "voucher_instructions"
    t.string   "teaser_image"
    t.decimal  "retail_value"
    t.decimal  "price"
    t.decimal  "revenue_shared"
    t.integer  "quantity"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "grid_weight"
    t.string   "destination"
    t.integer  "metro_id"
    t.integer  "vendor_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "main_image"
    t.string   "slug"
    t.string   "status",                  :limit => 16, :default => "Proposed", :null => false
    t.string   "promotion_type",          :limit => 16, :default => "Deal",     :null => false
    t.string   "subtitle"
    t.integer  "strategy_id"
    t.string   "strategy_type"
    t.integer  "min_per_customer",                      :default => 1,          :null => false
    t.integer  "max_per_customer",                      :default => 0,          :null => false
    t.boolean  "suspended",                             :default => false,      :null => false
    t.string   "venue_address",           :limit => 50
    t.string   "venue_city",              :limit => 50
    t.string   "venue_state",             :limit => 2
    t.string   "venue_zipcode",           :limit => 10
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.boolean  "pending",                               :default => false,      :null => false
    t.string   "venue_name",              :limit => 50
    t.boolean  "requires_prior_purchase",               :default => false,      :null => false
    t.boolean  "teaser_image_processing"
    t.boolean  "main_image_processing"
    t.integer  "anonymous_clicks",                      :default => 0,          :null => false
    t.string   "venue_phone",             :limit => 14
    t.string   "venue_url"
  end

  add_index "promotions", ["slug"], :name => "index_promotions_on_slug"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month"
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "ratings", :force => true do |t|
    t.integer  "stars"
    t.text     "comment"
    t.integer  "idea_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ratings", ["idea_id", "user_id"], :name => "index_ratings_on_idea_id_and_user_id", :unique => true

  create_table "relative_expiration_strategies", :force => true do |t|
    t.integer  "period_days",                :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "delay_hours", :default => 0, :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name",             :limit => 24
    t.string   "last_name",              :limit => 48
    t.string   "address_1",              :limit => 50
    t.string   "address_2",              :limit => 50
    t.string   "city",                   :limit => 50
    t.string   "state",                  :limit => 2
    t.string   "zipcode",                :limit => 5
    t.string   "phone",                  :limit => 14
    t.boolean  "optin",                                :default => false, :null => false
    t.decimal  "total_macho_bucks",                    :default => 0.0
    t.string   "customer_id",            :limit => 25
    t.integer  "metro_id"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "facebook"
    t.string   "phone"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "user_id"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "slug"
    t.boolean  "private_address", :default => false
    t.string   "source"
    t.string   "logo_image"
    t.string   "notes"
  end

  create_table "videos", :force => true do |t|
    t.string   "destination_url"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "title",           :limit => 50
    t.integer  "curator_id"
    t.text     "caption"
    t.string   "slug"
    t.string   "source",          :limit => 24
  end

  create_table "vouchers", :force => true do |t|
    t.string   "uuid"
    t.datetime "redemption_date"
    t.string   "status",          :limit => 16, :default => "Available"
    t.text     "notes"
    t.datetime "expiration_date"
    t.datetime "valid_date"
    t.integer  "order_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "slug"
    t.integer  "payment_id"
    t.integer  "delay_hours"
  end

  add_index "vouchers", ["slug"], :name => "index_vouchers_on_slug"
  add_index "vouchers", ["uuid"], :name => "index_vouchers_on_uuid", :unique => true

end
