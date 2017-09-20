class CreateGroupMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :group_members do |t|
      t.references :group, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :role

      t.timestamps null: false
    end
  end
end
