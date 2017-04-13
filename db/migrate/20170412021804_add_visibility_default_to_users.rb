class AddVisibilityDefaultToUsers < ActiveRecord::Migration
  def change
    add_column :users, :visibility_default, :integer, null: false, default: 0
  end
end
