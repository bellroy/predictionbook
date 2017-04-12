class AddGroupToPredictions < ActiveRecord::Migration
  def change
    add_reference :predictions, :group, index: true, foreign_key: true
  end
end
