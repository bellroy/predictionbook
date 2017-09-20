class InitialSchema < ActiveRecord::Migration[4.2]
  def self.up
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

    add_index "notifications", ["user_id"], :name => "index_deadline_notifications_on_user_id"
    add_index "notifications", ["prediction_id"], :name => "index_deadline_notifications_on_prediction_id"

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

    add_index "predictions", ["uuid"], :name => "index_predictions_on_uuid", :unique => true
    add_index "predictions", ["creator_id"], :name => "index_predictions_on_creator_id"

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
    end

    add_index "users", ["login"], :name => "index_users_on_login", :unique => true

    create_table "wagers", :force => true do |t|
      t.integer  "prediction_id"
      t.string   "name"
      t.integer  "confidence"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    raise "not implemented"
  end
end
