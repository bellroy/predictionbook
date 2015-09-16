class ChangeAnswerValueStorage < ActiveRecord::Migration
  def up
    rename_column :credence_answers, :display_val, :value
    remove_column :credence_answers, :real_val
    add_column :credence_answers, :rank, :integer
  end

  def down
    rename_column :credence_answers, :value, :display_val
    add_column :credence_answers, :real_val, :float
    remove_column :credence_answers, :rank
  end
end
