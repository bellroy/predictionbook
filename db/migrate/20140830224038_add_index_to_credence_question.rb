class AddIndexToCredenceQuestion < ActiveRecord::Migration
  def change
    add_index :credence_questions, [:credence_game_id, :asked_at]
  end
end
