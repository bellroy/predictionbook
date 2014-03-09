class CreateCredenceQuestions < ActiveRecord::Migration
  def change
    create_table :credence_questions do |t|
      t.integer :credence_question_generator_id
      t.integer :answer0_id
      t.integer :answer1_id
      t.boolean :answer0_correct

      t.timestamps
    end
  end
end
