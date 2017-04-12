class AddGroupDefaultToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :group_default, index: true
    add_foreign_key :users, :groups, column: :group_default_id
  end
end
