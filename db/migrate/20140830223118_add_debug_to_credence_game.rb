class AddDebugToCredenceGame < ActiveRecord::Migration
  def change
    add_column :credence_games, :debug, :boolean, default: false, null: false
  end
end
