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

ActiveRecord::Schema.define(:version => 20120909163821) do

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

  create_table "promotions", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "limitations"
    t.string   "voucher_instructions"
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
  end

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

end
