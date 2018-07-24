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

ActiveRecord::Schema.define(version: 2017_06_26_055158) do

  create_table "credence_answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "credence_question_id"
    t.text "text"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank"
    t.index ["credence_question_id"], name: "index_credence_answers_on_credence_question_id"
  end

  create_table "credence_game_responses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "credence_question_id"
    t.integer "first_answer_id"
    t.integer "second_answer_id"
    t.integer "correct_index"
    t.integer "credence_game_id"
    t.datetime "asked_at"
    t.datetime "answered_at"
    t.integer "answer_credence"
    t.integer "given_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credence_game_id", "asked_at"], name: "index_credence_game_responses_on_credence_game_id_and_asked_at"
    t.index ["credence_question_id"], name: "index_credence_game_responses_on_credence_question_id"
  end

  create_table "credence_games", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "current_response_id"
    t.integer "score", default: 0, null: false
    t.integer "user_id"
    t.integer "num_answered", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credence_games_on_user_id", unique: true
  end

  create_table "credence_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "enabled"
    t.string "text"
    t.string "prefix"
    t.string "suffix"
    t.string "question_type"
    t.integer "adjacent_within"
    t.float "weight"
    t.string "text_id", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text_id"], name: "index_credence_questions_on_text_id", unique: true
  end

  create_table "group_members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "judgements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "prediction_id"
    t.integer "user_id"
    t.boolean "outcome"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["prediction_id"], name: "index_judgements_on_prediction_id"
    t.index ["user_id"], name: "index_judgements_on_user_id"
  end

  create_table "notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "prediction_id"
    t.integer "user_id"
    t.boolean "sent", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "enabled", default: true
    t.string "uuid"
    t.boolean "token_used", default: false
    t.string "type"
    t.boolean "new_activity", default: false
    t.index ["prediction_id"], name: "index_deadline_notifications_on_prediction_id"
    t.index ["user_id"], name: "index_deadline_notifications_on_user_id"
  end

  create_table "prediction_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prediction_versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "prediction_id"
    t.integer "version"
    t.string "description"
    t.datetime "deadline"
    t.integer "creator_id"
    t.string "uuid"
    t.boolean "withdrawn", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "visibility", default: 0, null: false
  end

  create_table "predictions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "description"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.string "uuid"
    t.boolean "withdrawn", default: false
    t.integer "version", default: 1
    t.integer "visibility", default: 0, null: false
    t.integer "group_id"
    t.integer "prediction_group_id"
    t.index ["creator_id"], name: "index_predictions_on_creator_id"
    t.index ["group_id"], name: "index_predictions_on_group_id"
    t.index ["prediction_group_id"], name: "index_predictions_on_prediction_group_id"
    t.index ["uuid"], name: "index_predictions_on_uuid", unique: true
    t.index ["visibility"], name: "index_predictions_on_visibility"
  end

  create_table "responses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "prediction_id"
    t.integer "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "comment"
    t.integer "user_id"
    t.index ["prediction_id"], name: "index_responses_on_prediction_id"
    t.index ["user_id"], name: "index_responses_on_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "login"
    t.string "name"
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.string "remember_token", limit: 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "timezone"
    t.boolean "admin", default: false, null: false
    t.string "api_token"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "visibility_default", default: 0, null: false
    t.integer "group_default_id"
    t.string "confirmation_token"
    t.string "unconfirmed_email"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_default_id"], name: "index_users_on_group_default_id"
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wagers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "prediction_id"
    t.string "name"
    t.integer "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "users"
  add_foreign_key "predictions", "groups"
  add_foreign_key "predictions", "prediction_groups"
  add_foreign_key "users", "groups", column: "group_default_id"
end
