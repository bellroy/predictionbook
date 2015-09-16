class ChangeQuestionCorrectStorage < ActiveRecord::Migration
  def up
    rename_column :credence_game_responses, :first_answer_correct, :correct_index
    change_column :credence_game_responses, :correct_index, :integer
  end

  def down
    rename_column :credence_game_responses, :correct_index, :first_answer_correct
    change_column :credence_game_responses, :first_answer_correct, :boolean
  end
end
