class DropPrivateDefaultFlagFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :private_default, :boolean, default: false
  end
end
