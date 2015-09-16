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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150701042203) do

  create_table "credence_answers", :force => true do |t|
    t.integer  "credence_question_id"
    t.text     "text"
    t.text     "value"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "rank"
  end

  create_table "credence_game_responses", :force => true do |t|
    t.integer  "credence_question_id"
    t.integer  "first_answer_id"
    t.integer  "second_answer_id"
    t.integer  "correct_index"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "credence_game_id"
    t.datetime "asked_at"
    t.datetime "answered_at"
    t.integer  "answer_credence"
    t.integer  "given_answer"
  end

  add_index "credence_game_responses", ["credence_game_id", "asked_at"], :name => "index_credence_game_responses_on_credence_game_id_and_asked_at"

  create_table "credence_games", :force => true do |t|
    t.integer  "current_response_id"
    t.integer  "score",               :default => 0, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "user_id"
    t.integer  "num_answered",        :default => 0, :null => false
  end

  create_table "credence_questions", :force => true do |t|
    t.boolean  "enabled"
    t.string   "text"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "type"
    t.integer  "adjacent_within"
    t.float    "weight"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "judgements", :force => true do |t|
    t.integer  "prediction_id"
    t.integer  "user_id"
    t.boolean  "outcome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judgements", ["prediction_id"], :name => "index_judgements_on_prediction_id"
  add_index "judgements", ["user_id"], :name => "index_judgements_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "prediction_id"
    t.integer  "user_id"
    t.boolean  "sent",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",       :default => true
    t.string   "uuid"
    t.boolean  "token_used",    :default => false
    t.string   "type"
    t.boolean  "new_activity",  :default => false
  end

  add_index "notifications", ["prediction_id"], :name => "index_deadline_notifications_on_prediction_id"
  add_index "notifications", ["user_id"], :name => "index_deadline_notifications_on_user_id"

  create_table "prediction_versions", :force => true do |t|
    t.integer  "prediction_id"
    t.integer  "version"
    t.string   "description"
    t.datetime "deadline"
    t.integer  "creator_id"
    t.string   "uuid"
    t.boolean  "withdrawn",     :default => false
    t.boolean  "private",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predictions", :force => true do |t|
    t.string   "description"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "uuid"
    t.boolean  "withdrawn",   :default => false
    t.boolean  "private",     :default => false
    t.integer  "version",     :default => 1
  end

  add_index "predictions", ["creator_id"], :name => "index_predictions_on_creator_id"
  add_index "predictions", ["uuid"], :name => "index_predictions_on_uuid", :unique => true

  create_table "responses", :force => true do |t|
    t.integer  "prediction_id"
    t.integer  "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.integer  "user_id"
  end

  add_index "responses", ["prediction_id"], :name => "index_responses_on_prediction_id"
  add_index "responses", ["user_id"], :name => "index_responses_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
    t.boolean  "private_default",                         :default => false
    t.boolean  "admin",                                   :default => false, :null => false
    t.string   "api_token"
  end

  add_index "users", ["api_token"], :name => "index_users_on_api_token"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "wagers", :force => true do |t|
    t.integer  "prediction_id"
    t.string   "name"
    t.integer  "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
