class CreateCredenceQuestions < ActiveRecord::Migration
  def change
    create_table :credence_questions do |t|
      t.boolean :enabled
      t.string :text
      t.string :prefix
      t.string :suffix
      t.string :type
      t.integer :adjacent_within
      t.float :weight

      t.timestamps
    end
  end
end
