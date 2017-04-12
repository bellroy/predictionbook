class AddVisibilityToPredictions < ActiveRecord::Migration
  def change
    add_column :predictions, :visibility, :integer, null: false, default: 0
  end
end
