class CreateCredenceQuestionGenerators < ActiveRecord::Migration
  def change
    create_table :credence_question_generators do |t|
      t.boolean :enabled
      t.string :text
      t.string :prefix
      t.string :suffix
      t.string :type
      t.integer :adjacentWithin
      t.float :weight

      t.timestamps
    end
  end
end
