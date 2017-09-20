class AddVisibilityDefaultToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :visibility_default, :integer, null: false, default: 0
  end
end
