class DropPrivateFlagFromPredictionVersions < ActiveRecord::Migration
  def change
    remove_column :prediction_versions, :private, :boolean, default: false
  end
end
