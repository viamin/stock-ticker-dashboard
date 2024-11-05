# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_11_05_060441) do
  create_table "manipulations", force: :cascade do |t|
    t.text "message"
    t.string "category"
    t.string "manipulator"
    t.string "racc_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.string "value_type"
    t.string "newvalue"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "cents"
    t.datetime "date"
    t.integer "stock_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_prices_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.text "name"
    t.text "ticker"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "category"
    t.boolean "active", default: true, null: false
    t.index ["slug"], name: "index_stocks_on_slug", unique: true
  end

  add_foreign_key "prices", "stocks"
end
