class AddTextIdToCredenceQuestion < ActiveRecord::Migration
  def change
    add_column :credence_questions, :text_id, :string, limit: 50
    add_index :credence_questions, :text_id, unique: true
  end
end
