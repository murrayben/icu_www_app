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

ActiveRecord::Schema.define(version: 20131130163115) do

  create_table "bad_logins", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password", limit: 32
    t.string   "ip",                 limit: 50
    t.datetime "created_at"
  end

  create_table "clubs", force: true do |t|
    t.string   "county",     limit: 20
    t.string   "name",       limit: 50
    t.string   "city",       limit: 50
    t.string   "district",   limit: 50
    t.string   "contact",    limit: 50
    t.string   "email",      limit: 50
    t.string   "phone",      limit: 50
    t.string   "address",    limit: 100
    t.string   "web",        limit: 100
    t.string   "meet"
    t.boolean  "active"
    t.decimal  "lat",                    precision: 10, scale: 7
    t.decimal  "long",                   precision: 10, scale: 7
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_entries", force: true do |t|
    t.integer  "journalable_id"
    t.string   "journalable_type", limit: 50
    t.string   "action",           limit: 50
    t.string   "column",           limit: 50
    t.string   "by"
    t.string   "ip",               limit: 50
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
    t.string   "source",           limit: 8,  default: "www2"
  end

  add_index "journal_entries", ["journalable_id", "journalable_type"], name: "index_journal_entries_on_journalable_id_and_journalable_type", using: :btree

  create_table "logins", force: true do |t|
    t.integer  "user_id"
    t.string   "error"
    t.string   "roles"
    t.string   "ip",         limit: 50
    t.datetime "created_at"
  end

  create_table "players", force: true do |t|
    t.string   "first_name",         limit: 50
    t.string   "last_name",          limit: 50
    t.string   "status",             limit: 25
    t.string   "source",             limit: 25
    t.integer  "player_id"
    t.string   "gender",             limit: 1
    t.date     "dob"
    t.date     "joined"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "club_id"
    t.string   "fed",                limit: 3
    t.string   "player_title",       limit: 3
    t.string   "arbiter_title",      limit: 3
    t.string   "trainer_title",      limit: 3
    t.string   "email",              limit: 50
    t.string   "address"
    t.string   "home_phone",         limit: 30
    t.string   "mobile_phone",       limit: 30
    t.string   "work_phone",         limit: 30
    t.text     "note"
    t.integer  "legacy_rating",      limit: 2
    t.string   "legacy_rating_type", limit: 20
    t.integer  "legacy_games",       limit: 2
  end

  add_index "players", ["first_name", "last_name"], name: "index_players_on_first_name_and_last_name", using: :btree
  add_index "players", ["first_name"], name: "index_players_on_first_name", using: :btree
  add_index "players", ["last_name"], name: "index_players_on_last_name", using: :btree

  create_table "translations", force: true do |t|
    t.string   "locale",      limit: 2
    t.string   "key"
    t.string   "value"
    t.string   "english"
    t.string   "old_english"
    t.string   "user"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "roles"
    t.string   "encrypted_password", limit: 32
    t.string   "salt",               limit: 32
    t.string   "status",                        default: "OK"
    t.integer  "player_id"
    t.date     "expires_on"
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "theme",              limit: 16
    t.string   "locale",             limit: 2,  default: "en"
  end

end
