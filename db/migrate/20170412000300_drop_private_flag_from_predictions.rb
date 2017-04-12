class DropPrivateFlagFromPredictions < ActiveRecord::Migration
  def change
    remove_column :predictions, :private, :boolean, default: false
  end
end
