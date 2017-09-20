class AddUuidToGroupMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :group_members, :uuid, :string, limit: 255
  end
end
