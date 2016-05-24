class RemoveUnusedUserFields < ActiveRecord::Migration
  def change
    remove_column :users, :crypted_password, :string, limit: 40
    remove_column :users, :salt, :string, limit: 40
  end
end
