class AddGroupDefaultToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :group_default, index: true
    add_foreign_key :users, :groups, column: :group_default_id
  end
end
