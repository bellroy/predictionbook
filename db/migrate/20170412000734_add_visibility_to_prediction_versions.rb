class AddVisibilityToPredictionVersions < ActiveRecord::Migration
  def change
    add_column :prediction_versions, :visibility, :integer, null: false, default: 0
  end
end
