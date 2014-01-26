class CreateCredenceGames < ActiveRecord::Migration
  def change
    create_table :credence_games do |t|
      t.integer :current_question_id
      t.integer :score,               :null => false, :default => 0

      t.timestamps
    end
  end
end
