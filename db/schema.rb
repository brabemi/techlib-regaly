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

ActiveRecord::Schema.define(version: 20170929130152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "floors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "floor", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.index ["floor"], name: "index_floors_on_floor", unique: true
  end

  create_table "shelf_rows", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "segment_lengths", null: false
    t.integer "levels", null: false
    t.integer "row_length", null: false
    t.integer "row_width", null: false
    t.float "right_front_x", null: false
    t.float "right_front_y", null: false
    t.string "orientation", null: false
    t.uuid "floor_id", null: false
    t.index ["floor_id"], name: "index_shelf_rows_on_floor_id"
    t.index ["name"], name: "index_shelf_rows_on_name", unique: true
  end

  create_table "signatures", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "signature", null: false
    t.index ["signature"], name: "index_signatures_on_signature", unique: true
  end

  create_table "years", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "year", null: false
    t.integer "volumes", null: false
    t.uuid "signature_id", null: false
    t.index ["signature_id", "year"], name: "index_years_on_signature_id_and_year", unique: true
    t.index ["signature_id"], name: "index_years_on_signature_id"
  end

  add_foreign_key "shelf_rows", "floors", on_update: :cascade, on_delete: :cascade
  add_foreign_key "years", "signatures", on_update: :cascade, on_delete: :cascade
end
