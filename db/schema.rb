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

ActiveRecord::Schema.define(version: 20171103084854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "floors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "floor",  null: false
    t.integer "width",  null: false
    t.integer "height", null: false
    t.index ["floor"], name: "index_floors_on_floor", unique: true, using: :btree
  end

  create_table "shelf_rows", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string  "name",            null: false
    t.jsonb   "segment_lengths", null: false
    t.integer "levels",          null: false
    t.integer "row_length",      null: false
    t.integer "row_width",       null: false
    t.float   "right_front_x",   null: false
    t.float   "right_front_y",   null: false
    t.string  "orientation",     null: false
    t.uuid    "floor_id",        null: false
    t.index ["floor_id", "name"], name: "index_shelf_rows_on_floor_id_and_name", unique: true, using: :btree
    t.index ["floor_id"], name: "index_shelf_rows_on_floor_id", using: :btree
  end

  create_table "signatures", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string  "signature",        null: false
    t.string  "signature_prefix", null: false
    t.integer "signature_number", null: false
    t.integer "year_min",         null: false
    t.integer "year_max",         null: false
    t.integer "volumes_total",    null: false
    t.jsonb   "volumes",          null: false
    t.index ["signature"], name: "index_signatures_on_signature", unique: true, using: :btree
  end

  create_table "simulations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name",         null: false
    t.float  "volume_width", null: false
    t.jsonb  "shelfs",       null: false
    t.jsonb  "books",        null: false
  end

  add_foreign_key "shelf_rows", "floors", on_update: :cascade, on_delete: :cascade
end
