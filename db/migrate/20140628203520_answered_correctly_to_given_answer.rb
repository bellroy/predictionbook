class AnsweredCorrectlyToGivenAnswer < ActiveRecord::Migration
  def up
    rename_column :credence_game_responses, :answered_correctly, :given_answer
    change_column :credence_game_responses, :given_answer, :integer
  end

  def down
    rename_column :credence_game_responses, :given_answer, :answered_correctly
    change_column :credence_game_responses, :answered_correctly, :boolean
  end
end
