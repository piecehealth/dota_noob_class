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

ActiveRecord::Schema[8.1].define(version: 2026_03_03_102117) do
  create_table "classrooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_classrooms_on_number", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.integer "classroom_id", null: false
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_groups_on_classroom_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "assists", null: false
    t.integer "average_rank"
    t.datetime "created_at", null: false
    t.integer "deaths", null: false
    t.integer "duration", null: false
    t.integer "game_mode"
    t.integer "hero_id", null: false
    t.integer "hero_variant"
    t.integer "kills", null: false
    t.integer "leaver_status", default: 0, null: false
    t.integer "lobby_type"
    t.bigint "match_id", null: false
    t.boolean "on_radiant", null: false
    t.integer "party_size"
    t.datetime "played_at", null: false
    t.integer "player_slot", null: false
    t.text "raw_data", null: false
    t.integer "source", default: 2, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "won", null: false
    t.index ["match_id"], name: "index_matches_on_match_id"
    t.index ["played_at"], name: "index_matches_on_played_at"
    t.index ["user_id", "match_id"], name: "index_matches_on_user_id_and_match_id", unique: true
    t.index ["user_id"], name: "index_matches_on_user_id"
    t.check_constraint "source IN (0, 1, 2)", name: "check_matches_source"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "activated_at"
    t.string "activation_token", null: false
    t.integer "classroom_id"
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "dota2_player_id"
    t.integer "group_id"
    t.boolean "is_admin", default: false, null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["activation_token"], name: "index_users_on_activation_token", unique: true
    t.index ["classroom_id"], name: "index_users_on_classroom_id"
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["username"], name: "index_users_on_username", unique: true, where: "username IS NOT NULL"
  end

  add_foreign_key "groups", "classrooms"
  add_foreign_key "matches", "users"
  add_foreign_key "users", "classrooms"
  add_foreign_key "users", "groups"
end
