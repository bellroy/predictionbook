class AddVisibilityToPredictions < ActiveRecord::Migration[4.2]
  def change
    add_column :predictions, :visibility, :integer, null: false, default: 0
  end
end
