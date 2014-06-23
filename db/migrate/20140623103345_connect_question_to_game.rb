class ConnectQuestionToGame < ActiveRecord::Migration
  def up
    add_column :credence_questions, :credence_game_id, :integer
    add_column :credence_questions, :asked_at, :datetime
    add_column :credence_questions, :answered_at, :datetime
    add_column :credence_questions, :answer_credence, :integer
    add_column :credence_questions, :answered_correctly, :boolean
  end

  def down
    remove_column :credence_questions, :credence_game_id
    remove_column :credence_questions, :asked_at
    remove_column :credence_questions, :answered_at
    remove_column :credence_questions, :answer_credence
    remove_column :credence_questions, :answered_correctly
  end
end
