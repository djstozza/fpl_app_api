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

ActiveRecord::Schema.define(version: 20180501121327) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "draft_picks", force: :cascade do |t|
    t.integer "pick_number"
    t.boolean "mini_draft", default: false
    t.bigint "league_id"
    t.bigint "player_id"
    t.bigint "fpl_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_id"], name: "index_draft_picks_on_fpl_team_id"
    t.index ["league_id"], name: "index_draft_picks_on_league_id"
    t.index ["player_id"], name: "index_draft_picks_on_player_id"
  end

  create_table "fixtures", force: :cascade do |t|
    t.datetime "kickoff_time"
    t.datetime "deadline_time"
    t.integer "team_h_difficulty"
    t.integer "team_a_difficulty"
    t.integer "code"
    t.integer "team_h_score"
    t.integer "team_a_score"
    t.integer "minutes"
    t.boolean "started"
    t.boolean "finished"
    t.boolean "provisional_start_time"
    t.boolean "finished_provisional"
    t.integer "round_day"
    t.jsonb "stats"
    t.bigint "round_id"
    t.bigint "team_h_id"
    t.bigint "team_a_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["round_id"], name: "index_fixtures_on_round_id"
    t.index ["team_a_id"], name: "index_fixtures_on_team_a_id"
    t.index ["team_h_id"], name: "index_fixtures_on_team_h_id"
  end

  create_table "fpl_team_lists", force: :cascade do |t|
    t.bigint "fpl_team_id"
    t.bigint "round_id"
    t.integer "total_score"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "overall_rank"
    t.index ["fpl_team_id"], name: "index_fpl_team_lists_on_fpl_team_id"
    t.index ["round_id"], name: "index_fpl_team_lists_on_round_id"
  end

  create_table "fpl_teams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.bigint "league_id"
    t.integer "total_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "draft_pick_number"
    t.integer "mini_draft_pick_number"
    t.integer "rank"
    t.index ["league_id"], name: "index_fpl_teams_on_league_id"
    t.index ["name"], name: "index_fpl_teams_on_name", unique: true
    t.index ["user_id"], name: "index_fpl_teams_on_user_id"
  end

  create_table "fpl_teams_players", id: false, force: :cascade do |t|
    t.bigint "fpl_team_id", null: false
    t.bigint "player_id", null: false
    t.index ["fpl_team_id"], name: "index_fpl_teams_players_on_fpl_team_id"
    t.index ["player_id"], name: "index_fpl_teams_players_on_player_id"
  end

  create_table "inter_team_trade_groups", force: :cascade do |t|
    t.bigint "out_fpl_team_list_id"
    t.bigint "in_fpl_team_list_id"
    t.bigint "round_id"
    t.bigint "league_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["in_fpl_team_list_id"], name: "index_inter_team_trade_groups_on_in_fpl_team_list_id"
    t.index ["league_id"], name: "index_inter_team_trade_groups_on_league_id"
    t.index ["out_fpl_team_list_id"], name: "index_inter_team_trade_groups_on_out_fpl_team_list_id"
    t.index ["round_id"], name: "index_inter_team_trade_groups_on_round_id"
  end

  create_table "inter_team_trades", force: :cascade do |t|
    t.bigint "inter_team_trade_group_id"
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["in_player_id"], name: "index_inter_team_trades_on_in_player_id"
    t.index ["inter_team_trade_group_id"], name: "index_inter_team_trades_on_inter_team_trade_group_id"
    t.index ["out_player_id"], name: "index_inter_team_trades_on_out_player_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "commissioner_id"
    t.integer "status", default: 0
    t.index ["commissioner_id"], name: "index_leagues_on_commissioner_id"
    t.index ["name"], name: "index_leagues_on_name", unique: true
  end

  create_table "leagues_players", id: false, force: :cascade do |t|
    t.bigint "league_id", null: false
    t.bigint "player_id", null: false
    t.index ["league_id"], name: "index_leagues_players_on_league_id"
    t.index ["player_id"], name: "index_leagues_players_on_player_id"
  end

  create_table "list_positions", force: :cascade do |t|
    t.bigint "fpl_team_list_id"
    t.bigint "player_id"
    t.bigint "position_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_list_id"], name: "index_list_positions_on_fpl_team_list_id"
    t.index ["player_id"], name: "index_list_positions_on_player_id"
    t.index ["position_id"], name: "index_list_positions_on_position_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "squad_number"
    t.integer "team_code"
    t.string "photo"
    t.string "web_name"
    t.string "status"
    t.integer "code"
    t.string "news"
    t.integer "now_cost"
    t.integer "chance_of_playing_this_round"
    t.integer "chance_of_playing_next_round"
    t.decimal "value_form"
    t.decimal "value_season"
    t.integer "cost_change_start"
    t.integer "cost_change_event"
    t.integer "cost_change_start_fall"
    t.integer "cost_change_event_fall"
    t.boolean "in_dreamteam"
    t.integer "dreamteam_count"
    t.decimal "selected_by_percent"
    t.decimal "form"
    t.integer "transfers_out"
    t.integer "transfers_in"
    t.integer "transfers_out_event"
    t.integer "transfers_in_event"
    t.integer "loans_in"
    t.integer "loans_out"
    t.integer "loaned_in"
    t.integer "loaned_out"
    t.integer "total_points"
    t.integer "event_points"
    t.decimal "points_per_game"
    t.decimal "ep_this"
    t.decimal "ep_next"
    t.boolean "special"
    t.integer "minutes"
    t.integer "goals_scored"
    t.integer "assists"
    t.integer "clean_sheets"
    t.integer "goals_conceded"
    t.integer "own_goals"
    t.integer "penalties_saved"
    t.integer "penalties_missed"
    t.integer "yellow_cards"
    t.integer "red_cards"
    t.integer "saves"
    t.integer "bonus"
    t.integer "bps"
    t.decimal "influence"
    t.decimal "creativity"
    t.decimal "threat"
    t.decimal "ict_index"
    t.integer "open_play_crosses"
    t.integer "big_chances_created"
    t.integer "clearances_blocks_interceptions"
    t.integer "recoveries"
    t.integer "key_passes"
    t.integer "tackles"
    t.integer "winning_goals"
    t.integer "dribbles"
    t.integer "fouls"
    t.integer "errors_leading_to_goal"
    t.integer "big_chances_missed"
    t.integer "offside"
    t.integer "attempted_passes"
    t.integer "target_missed"
    t.integer "ea_index"
    t.jsonb "player_fixture_histories"
    t.jsonb "player_past_histories"
    t.bigint "position_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id"], name: "index_players_on_position_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "singular_name"
    t.string "singular_name_short"
    t.string "plural_name"
    t.string "plural_name_short"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.string "name"
    t.datetime "deadline_time"
    t.boolean "finished"
    t.boolean "data_checked"
    t.integer "deadline_time_epoch"
    t.integer "deadline_time_game_offset"
    t.boolean "is_previous"
    t.boolean "is_current"
    t.boolean "is_next"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mini_draft"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "short_name"
    t.integer "strength"
    t.integer "position"
    t.integer "played"
    t.integer "wins"
    t.integer "losses"
    t.integer "draws"
    t.integer "clean_sheets"
    t.integer "goals_for"
    t.integer "goals_against"
    t.integer "goal_difference"
    t.integer "points"
    t.jsonb "form"
    t.string "current_form"
    t.integer "link_url"
    t.integer "strength_overall_home"
    t.integer "strength_overall_away"
    t.integer "strength_attack_home"
    t.integer "strength_attack_away"
    t.integer "strength_defence_home"
    t.integer "strength_defence_away"
    t.integer "team_division"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "username", null: false
    t.string "image"
    t.string "email", null: false
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "waiver_picks", force: :cascade do |t|
    t.integer "pick_number"
    t.integer "status", default: 0
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.bigint "fpl_team_list_id"
    t.bigint "round_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_list_id"], name: "index_waiver_picks_on_fpl_team_list_id"
    t.index ["in_player_id"], name: "index_waiver_picks_on_in_player_id"
    t.index ["league_id"], name: "index_waiver_picks_on_league_id"
    t.index ["out_player_id"], name: "index_waiver_picks_on_out_player_id"
    t.index ["round_id"], name: "index_waiver_picks_on_round_id"
  end

  add_foreign_key "inter_team_trade_groups", "fpl_team_lists", column: "in_fpl_team_list_id"
  add_foreign_key "inter_team_trade_groups", "fpl_team_lists", column: "out_fpl_team_list_id"
  add_foreign_key "inter_team_trades", "players", column: "in_player_id"
  add_foreign_key "inter_team_trades", "players", column: "out_player_id"
  add_foreign_key "leagues", "users", column: "commissioner_id"
  add_foreign_key "waiver_picks", "players", column: "in_player_id"
  add_foreign_key "waiver_picks", "players", column: "out_player_id"
end
