class AddScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :score, :float, default: 1.0
  end
end
