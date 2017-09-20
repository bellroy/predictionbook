class DropPrivateFlagFromPredictions < ActiveRecord::Migration[4.2]
  def change
    remove_column :predictions, :private, :boolean, default: false
  end
end
