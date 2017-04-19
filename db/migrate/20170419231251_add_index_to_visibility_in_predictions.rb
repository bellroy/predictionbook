class AddIndexToVisibilityInPredictions < ActiveRecord::Migration
  def change
    add_index :predictions, :visibility
  end
end
