class AddIndexToVisibilityInPredictions < ActiveRecord::Migration[4.2]
  def change
    add_index :predictions, :visibility
  end
end
