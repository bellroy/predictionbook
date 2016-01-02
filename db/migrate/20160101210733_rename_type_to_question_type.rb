# Rails uses columns named `type` for specific purposes, so we can't use it.
class RenameTypeToQuestionType < ActiveRecord::Migration
  def change
    rename_column :credence_questions, :type, :question_type
  end
end
