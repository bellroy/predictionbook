class AddGroupToPredictions < ActiveRecord::Migration[4.2]
  def change
    add_reference :predictions, :group, index: true, foreign_key: true
  end
end
