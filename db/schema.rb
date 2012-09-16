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

ActiveRecord::Schema.define(:version => 20120916040109) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.boolean  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories_promotions", :force => true do |t|
    t.integer "category_id"
    t.integer "promotion_id"
  end

  create_table "metros", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "orders", :force => true do |t|
    t.string   "description"
    t.string   "email"
    t.decimal  "amount"
    t.string   "stripe_card_token"
    t.integer  "promotion_id"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "promotion_images", :force => true do |t|
    t.string   "name"
    t.string   "imageurl"
    t.string   "mediatype"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "promotion_images_promotions", :force => true do |t|
    t.integer "promotion_id"
    t.integer "promotion_image_id"
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
    t.datetime "start"
    t.datetime "end"
    t.integer  "grid_weight"
    t.string   "destination"
    t.integer  "metro_id"
    t.integer  "vendor_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "main_image"
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
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

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "fbook"
    t.string   "phone"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "videos", :force => true do |t|
    t.string   "name"
    t.string   "destination"
    t.boolean  "active"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "vouchers", :force => true do |t|
    t.string   "uuid"
    t.datetime "redemption_date"
    t.string   "status"
    t.text     "notes"
    t.datetime "expiration_date"
    t.datetime "issue_date"
    t.integer  "promotion_id"
    t.integer  "order_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
