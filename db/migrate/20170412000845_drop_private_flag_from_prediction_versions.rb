class DropPrivateFlagFromPredictionVersions < ActiveRecord::Migration[4.2]
  def change
    remove_column :prediction_versions, :private, :boolean, default: false
  end
end
