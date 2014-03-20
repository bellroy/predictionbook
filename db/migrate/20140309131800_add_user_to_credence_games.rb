class AddUserToCredenceGames < ActiveRecord::Migration
  def change
    add_column :credence_games, :user_id, :int
  end
end
