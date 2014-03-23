class ChangeQuestionCorrectStorage < ActiveRecord::Migration
  def up
    rename_column :credence_questions, :answer0_correct, :correct_index
    change_column :credence_questions, :correct_index, :integer
  end

  def down
    rename_column :credence_questions, :correct_index, :answer0_correct
    change_column :credence_questions, :answer0_correct, :boolean
  end
end
