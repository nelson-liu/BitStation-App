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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140824015852) do

  create_table "coinbase_accounts", force: true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "oauth_credentials"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "associated_transaction_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id"

  create_table "money_requests", force: true do |t|
    t.integer  "sender_id"
    t.integer  "requestee_id"
    t.integer  "status"
    t.decimal  "amount"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "dollar_amount"
  end

  create_table "notes", force: true do |t|
    t.integer  "user_id"
    t.text     "coinbase_transaction_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id"

  create_table "transactions", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipient_address"
    t.integer  "status"
    t.decimal  "fee_amount"
    t.integer  "money_request_id"
    t.boolean  "is_public"
    t.string   "coinbase_transaction_id"
    t.text     "message"
  end

  create_table "transfers", force: true do |t|
    t.decimal  "amount"
    t.decimal  "coinbase_fee"
    t.decimal  "bank_fee"
    t.decimal  "total_amount"
    t.string   "payment_method_id"
    t.string   "payment_method_name"
    t.integer  "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "subtotal"
    t.integer  "status"
  end

  create_table "users", force: true do |t|
    t.string   "kerberos"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "auth_token"
    t.string   "access_code"
    t.boolean  "access_code_redeemed"
  end

end
