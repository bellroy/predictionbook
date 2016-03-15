class AddForeignKeys < ActiveRecord::Migration
  # These aren't actually foreign keys in MySQL
  def change
    add_index :credence_games, :user_id
    add_index :credence_answers, :credence_question_id
    add_index :credence_game_responses, :credence_question_id
  end
end
