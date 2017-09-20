class AddVisibilityToPredictionVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :prediction_versions, :visibility, :integer, null: false, default: 0
  end
end
