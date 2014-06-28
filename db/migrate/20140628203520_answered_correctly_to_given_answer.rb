class AnsweredCorrectlyToGivenAnswer < ActiveRecord::Migration
  def up
    rename_column :credence_questions, :answered_correctly, :given_answer
    change_column :credence_questions, :given_answer, :integer
  end

  def down
    rename_column :credence_questions, :given_answer, :answered_correctly
    change_column :credence_questions, :answered_correctly, :boolean
  end
end
