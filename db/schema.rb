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

ActiveRecord::Schema.define(version: 20170412121536) do

  create_table "credence_answers", force: :cascade do |t|
    t.integer  "credence_question_id", limit: 4
    t.text     "text",                 limit: 65535
    t.text     "value",                limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "rank",                 limit: 4
  end

  add_index "credence_answers", ["credence_question_id"], name: "index_credence_answers_on_credence_question_id", using: :btree

  create_table "credence_game_responses", force: :cascade do |t|
    t.integer  "credence_question_id", limit: 4
    t.integer  "first_answer_id",      limit: 4
    t.integer  "second_answer_id",     limit: 4
    t.integer  "correct_index",        limit: 4
    t.integer  "credence_game_id",     limit: 4
    t.datetime "asked_at"
    t.datetime "answered_at"
    t.integer  "answer_credence",      limit: 4
    t.integer  "given_answer",         limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "credence_game_responses", ["credence_game_id", "asked_at"], name: "index_credence_game_responses_on_credence_game_id_and_asked_at", using: :btree
  add_index "credence_game_responses", ["credence_question_id"], name: "index_credence_game_responses_on_credence_question_id", using: :btree

  create_table "credence_games", force: :cascade do |t|
    t.integer  "current_response_id", limit: 4
    t.integer  "score",               limit: 4, default: 0, null: false
    t.integer  "user_id",             limit: 4
    t.integer  "num_answered",        limit: 4, default: 0, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "credence_games", ["user_id"], name: "index_credence_games_on_user_id", unique: true, using: :btree

  create_table "credence_questions", force: :cascade do |t|
    t.boolean  "enabled"
    t.string   "text",            limit: 255
    t.string   "prefix",          limit: 255
    t.string   "suffix",          limit: 255
    t.string   "question_type",   limit: 255
    t.integer  "adjacent_within", limit: 4
    t.float    "weight",          limit: 24
    t.string   "text_id",         limit: 50
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "credence_questions", ["text_id"], name: "index_credence_questions_on_text_id", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",          limit: 255, null: false
    t.string   "email_domains", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "judgements", force: :cascade do |t|
    t.integer  "prediction_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.boolean  "outcome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judgements", ["prediction_id"], name: "index_judgements_on_prediction_id", using: :btree
  add_index "judgements", ["user_id"], name: "index_judgements_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "prediction_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.boolean  "sent",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",                   default: true
    t.string   "uuid",          limit: 255
    t.boolean  "token_used",                default: false
    t.string   "type",          limit: 255
    t.boolean  "new_activity",              default: false
  end

  add_index "notifications", ["prediction_id"], name: "index_deadline_notifications_on_prediction_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_deadline_notifications_on_user_id", using: :btree

  create_table "prediction_versions", force: :cascade do |t|
    t.integer  "prediction_id", limit: 4
    t.integer  "version",       limit: 4
    t.string   "description",   limit: 255
    t.datetime "deadline"
    t.integer  "creator_id",    limit: 4
    t.string   "uuid",          limit: 255
    t.boolean  "withdrawn",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visibility",    limit: 4,   default: 0,     null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  limit: 4
    t.string   "uuid",        limit: 255
    t.boolean  "withdrawn",               default: false
    t.integer  "version",     limit: 4,   default: 1
    t.integer  "visibility",  limit: 4,   default: 0,     null: false
    t.integer  "group_id",    limit: 4
  end

  add_index "predictions", ["creator_id"], name: "index_predictions_on_creator_id", using: :btree
  add_index "predictions", ["group_id"], name: "index_predictions_on_group_id", using: :btree
  add_index "predictions", ["uuid"], name: "index_predictions_on_uuid", unique: true, using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "prediction_id", limit: 4
    t.integer  "confidence",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment",       limit: 255
    t.integer  "user_id",       limit: 4
  end

  add_index "responses", ["prediction_id"], name: "index_responses_on_prediction_id", using: :btree
  add_index "responses", ["user_id"], name: "index_responses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "name",                      limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone",                  limit: 255
    t.boolean  "admin",                                 default: false, null: false
    t.string   "api_token",                 limit: 255
    t.string   "encrypted_password",        limit: 255, default: "",    null: false
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.integer  "visibility_default",        limit: 4,   default: 0,     null: false
    t.integer  "group_default_id",          limit: 4
  end

  add_index "users", ["api_token"], name: "index_users_on_api_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_default_id"], name: "index_users_on_group_default_id", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wagers", force: :cascade do |t|
    t.integer  "prediction_id", limit: 4
    t.string   "name",          limit: 255
    t.integer  "confidence",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "predictions", "groups"
  add_foreign_key "users", "groups", column: "group_default_id"
end
