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

ActiveRecord::Schema[8.1].define(version: 2026_04_06_052443) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_errors", force: :cascade do |t|
    t.string "api_name", null: false
    t.string "context"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "error_type"
    t.string "steam_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["api_name"], name: "index_api_errors_on_api_name"
    t.index ["created_at"], name: "index_api_errors_on_created_at"
  end

  create_table "classrooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_classrooms_on_number", unique: true
  end

  create_table "daily_stats", force: :cascade do |t|
    t.float "avg_kda", default: 0.0
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "end_of_day_rank"
    t.integer "losses_count", default: 0, null: false
    t.integer "matches_count", default: 0, null: false
    t.integer "rank_change", default: 0
    t.integer "total_assists", default: 0, null: false
    t.integer "total_deaths", default: 0, null: false
    t.integer "total_duration", default: 0, null: false
    t.integer "total_kills", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "wins_count", default: 0, null: false
    t.index ["date", "matches_count"], name: "index_daily_stats_on_date_and_matches_count"
    t.index ["date"], name: "index_daily_stats_on_date"
    t.index ["user_id", "date"], name: "index_daily_stats_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_stats_on_user_id"
  end

  create_table "exception_tracks", force: :cascade do |t|
    t.text "body", limit: 16777215
    t.datetime "created_at", precision: nil, null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "groups", force: :cascade do |t|
    t.integer "classroom_id", null: false
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_groups_on_classroom_id"
  end

  create_table "match_players", force: :cascade do |t|
    t.integer "assists", default: 0
    t.string "award"
    t.datetime "created_at", precision: nil, null: false
    t.integer "deaths", default: 0
    t.integer "hero_id"
    t.integer "hero_variant"
    t.integer "imp"
    t.boolean "is_mvp"
    t.boolean "is_svp"
    t.integer "kills", default: 0
    t.string "lane"
    t.string "lane_advantage"
    t.string "lane_outcome"
    t.integer "leaver_status", default: 0
    t.integer "match_id", null: false
    t.boolean "on_radiant"
    t.integer "party_size", default: 1
    t.integer "player_slot"
    t.string "position"
    t.json "raw_data"
    t.string "role"
    t.integer "source", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.boolean "won"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "average_rank"
    t.datetime "created_at", null: false
    t.integer "duration", null: false
    t.integer "game_mode"
    t.integer "lobby_type"
    t.bigint "match_id", null: false
    t.datetime "played_at", null: false
    t.json "raw_data"
    t.integer "source", default: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_matches_on_match_id"
    t.index ["match_id"], name: "index_matches_on_user_id_and_match_id", unique: true
    t.index ["played_at"], name: "index_matches_on_played_at"
    t.check_constraint "source IN (0, 1, 2)", name: "check_matches_source"
  end

  create_table "matches_new", force: :cascade do |t|
    t.integer "average_rank"
    t.datetime "created_at", precision: nil, null: false
    t.integer "duration", null: false
    t.integer "game_mode"
    t.integer "lobby_type"
    t.integer "match_id", null: false
    t.datetime "played_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "rank_snapshots", force: :cascade do |t|
    t.datetime "captured_at", null: false
    t.datetime "created_at", null: false
    t.integer "match_count", default: 0, null: false
    t.integer "rank", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "win_count", default: 0, null: false
    t.index ["captured_at"], name: "index_rank_snapshots_on_captured_at"
    t.index ["user_id", "captured_at"], name: "index_rank_snapshots_on_user_id_and_captured_at"
    t.index ["user_id"], name: "index_rank_snapshots_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "activated_at"
    t.string "activation_token", null: false
    t.integer "classroom_id"
    t.datetime "created_at", null: false
    t.integer "current_rank", default: 0
    t.string "display_name", null: false
    t.string "dota2_player_id"
    t.integer "group_id"
    t.integer "highest_rank", default: 0
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_dota2_id_invalid", default: false, null: false
    t.string "password_digest", null: false
    t.datetime "rank_updated_at"
    t.integer "role", default: 0, null: false
    t.integer "total_matches", default: 0
    t.integer "total_wins", default: 0
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["activation_token"], name: "index_users_on_activation_token", unique: true
    t.index ["classroom_id"], name: "index_users_on_classroom_id"
    t.index ["current_rank"], name: "index_users_on_current_rank"
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["rank_updated_at"], name: "index_users_on_rank_updated_at"
    t.index ["username"], name: "index_users_on_username", unique: true, where: "username IS NOT NULL"
  end

  create_table "weekly_leaderboards", force: :cascade do |t|
    t.integer "classroom_id"
    t.datetime "created_at", null: false
    t.json "details"
    t.integer "entity_id"
    t.string "entity_name"
    t.string "entity_type"
    t.integer "group_id"
    t.string "metric_type"
    t.integer "rank"
    t.datetime "updated_at", null: false
    t.integer "value"
    t.date "week_end"
    t.date "week_start"
    t.index ["classroom_id"], name: "index_weekly_leaderboards_on_classroom_id"
    t.index ["entity_id"], name: "index_weekly_leaderboards_on_entity_id"
    t.index ["metric_type", "entity_type", "week_start"], name: "index_weekly_leaderboards_on_metric_type_and_entity"
    t.index ["rank"], name: "index_weekly_leaderboards_on_rank"
    t.index ["week_start", "metric_type"], name: "index_weekly_leaderboards_on_week_start_and_metric_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "daily_stats", "users"
  add_foreign_key "groups", "classrooms"
  add_foreign_key "rank_snapshots", "users"
  add_foreign_key "users", "classrooms"
  add_foreign_key "users", "groups"
end
