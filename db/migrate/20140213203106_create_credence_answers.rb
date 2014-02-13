class CreateCredenceAnswers < ActiveRecord::Migration
  def change
    create_table :credence_answers do |t|
      t.belongs_to :credence_question_generator
      t.text :text
      t.float :real_val
      t.text :display_val

      t.timestamps
    end
  end
end
