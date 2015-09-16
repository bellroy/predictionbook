class AddNumAnsweredToCredenceGame < ActiveRecord::Migration
  def change
    add_column :credence_games, :num_answered, :integer, default: 0, null: false
  end
end
