class AddIndexToCredenceGameResponses < ActiveRecord::Migration
  def change
    add_index :credence_game_responses, [:credence_game_id, :asked_at]
  end
end
