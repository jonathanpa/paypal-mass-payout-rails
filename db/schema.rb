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

ActiveRecord::Schema.define(version: 20151216183726) do

  create_table "currencies", force: :cascade do |t|
    t.string   "code",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payees", force: :cascade do |t|
    t.string   "email"
    t.float    "balance"
    t.integer  "currency_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "payees", ["currency_id"], name: "index_payees_on_currency_id"

  create_table "payout_batches", force: :cascade do |t|
    t.string   "status"
    t.string   "sender_batch_id"
    t.string   "email_subject"
    t.float    "amount",          default: 0.0, null: false
    t.integer  "currency_id"
    t.float    "fees",            default: 0.0, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "paypal_id"
  end

  add_index "payout_batches", ["currency_id"], name: "index_payout_batches_on_currency_id"

  create_table "payout_items", force: :cascade do |t|
    t.string   "transaction_id"
    t.string   "transaction_status"
    t.float    "amount",             default: 0.0, null: false
    t.float    "fees",               default: 0.0, null: false
    t.string   "note"
    t.string   "sender_item_id"
    t.datetime "time_processed"
    t.integer  "payout_batch_id"
    t.integer  "currency_id"
    t.integer  "payee_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "paypal_id"
  end

  add_index "payout_items", ["currency_id"], name: "index_payout_items_on_currency_id"
  add_index "payout_items", ["payee_id"], name: "index_payout_items_on_payee_id"
  add_index "payout_items", ["payout_batch_id"], name: "index_payout_items_on_payout_batch_id"

end
