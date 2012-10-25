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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20121023232516) do
=======
ActiveRecord::Schema.define(:version => 20121020011131) do
>>>>>>> Updated front page design/layout

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "activity_name", :limit => 32, :null => false
    t.integer  "activity_id",                 :null => false
    t.string   "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "curator_id"
    t.datetime "posted_at"
    t.integer  "weight"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "blog_posts", ["slug"], :name => "index_blog_posts_on_slug"

  create_table "blog_posts_promotions", :id => false, :force => true do |t|
    t.integer "blog_post_id", :null => false
    t.integer "promotion_id", :null => false
  end

  add_index "blog_posts_promotions", ["blog_post_id", "promotion_id"], :name => "index_blog_posts_promotions_on_blog_post_id_and_promotion_id", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name",               :null => false
    t.boolean  "active"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "parent_category_id"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "categories_promotions", :id => false, :force => true do |t|
    t.integer "category_id",  :null => false
    t.integer "promotion_id", :null => false
  end

  add_index "categories_promotions", ["category_id", "promotion_id"], :name => "index_categories_promotions_on_category_id_and_promotion_id", :unique => true

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

  create_table "curators", :force => true do |t|
    t.string   "name"
    t.string   "picture"
    t.text     "bio"
    t.string   "twitter"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "curators", ["name"], :name => "index_curators_on_name", :unique => true
  add_index "curators", ["twitter"], :name => "index_curators_on_twitter", :unique => true

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "metros", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "metros", ["name"], :name => "index_metros_on_name", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "description"
    t.string   "email"
    t.decimal  "amount"
    t.string   "stripe_card_token"
    t.integer  "promotion_id"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "fine_print"
    t.integer  "quantity",          :default => 1, :null => false
    t.string   "charge_id"
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

  create_table "promotion_images", :force => true do |t|
    t.string   "caption",                    :limit => 64
    t.string   "media_type",                 :limit => 16
    t.string   "slideshow_image"
    t.string   "remote_slideshow_image_url"
    t.integer  "promotion_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
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
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "main_image"
    t.string   "slug"
    t.string   "status",               :limit => 16, :default => "Proposed", :null => false
    t.string   "promotion_type",       :limit => 16, :default => "Deal",     :null => false
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

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "stripe_id"
  end

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "videos", :force => true do |t|
    t.string   "name"
    t.string   "destination_url"
    t.boolean  "active"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "vouchers", :force => true do |t|
    t.string   "uuid"
    t.datetime "redemption_date"
    t.string   "status",          :limit => 16, :default => "Available"
    t.text     "notes"
    t.datetime "expiration_date"
    t.datetime "issue_date"
    t.integer  "order_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "slug"
  end

  add_index "vouchers", ["slug"], :name => "index_vouchers_on_slug"
  add_index "vouchers", ["uuid"], :name => "index_vouchers_on_uuid", :unique => true

end
