class DropPrivateDefaultFlagFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :private_default, :boolean, default: false
  end
end
