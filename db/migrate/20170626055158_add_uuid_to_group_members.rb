class AddUuidToGroupMembers < ActiveRecord::Migration
  def change
    add_column :group_members, :uuid, :string, limit: 255
  end
end
