class CreateCredenceGame < ActiveRecord::Migration
  def change
    create_table :credence_games do |t|
        t.integer  :current_response_id
        t.integer  :score,               :default => 0, :null => false
        t.integer  :user_id
        t.integer  :num_answered,        :default => 0, :null => false

        t.timestamps
    end

    add_index :credence_games, :user_id, :unique => true

    create_table :credence_questions do |t|
        t.boolean  :enabled
        t.string   :text
        t.string   :prefix
        t.string   :suffix
        t.string   :question_type
        t.integer  :adjacent_within
        t.float    :weight
        t.string   :text_id,         :limit => 50

        t.timestamps
    end

    add_index :credence_questions, :text_id, :unique => true

    create_table :credence_answers do |t|
        t.integer  :credence_question_id
        t.text     :text
        t.text     :value
        t.datetime :created_at,           :null => false
        t.datetime :updated_at,           :null => false
        t.integer  :rank

        t.timestamps
    end

    add_index :credence_answers, :credence_question_id

    create_table :credence_game_responses do |t|
        t.integer  :credence_question_id
        t.integer  :first_answer_id
        t.integer  :second_answer_id
        t.integer  :correct_index
        t.integer  :credence_game_id
        t.datetime :asked_at
        t.datetime :answered_at
        t.integer  :answer_credence
        t.integer  :given_answer

        t.timestamps
    end

    add_index :credence_game_responses, [:credence_game_id, :asked_at]
    add_index :credence_game_responses, :credence_question_id
  end
end
