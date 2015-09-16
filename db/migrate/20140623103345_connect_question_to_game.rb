class ConnectQuestionToGame < ActiveRecord::Migration
  def up
    add_column :credence_game_responses, :credence_game_id, :integer
    add_column :credence_game_responses, :asked_at, :datetime
    add_column :credence_game_responses, :answered_at, :datetime
    add_column :credence_game_responses, :answer_credence, :integer
    add_column :credence_game_responses, :answered_correctly, :boolean
  end

  def down
    remove_column :credence_game_responses, :credence_game_id
    remove_column :credence_game_responses, :asked_at
    remove_column :credence_game_responses, :answered_at
    remove_column :credence_game_responses, :answer_credence
    remove_column :credence_game_responses, :answered_correctly
  end
end
