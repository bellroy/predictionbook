class CreateCredenceGameResponses < ActiveRecord::Migration
  def change
    create_table :credence_game_responses do |t|
      t.integer :credence_question_id
      t.integer :first_answer_id
      t.integer :second_answer_id
      t.boolean :first_answer_correct

      t.timestamps
    end
  end
end
