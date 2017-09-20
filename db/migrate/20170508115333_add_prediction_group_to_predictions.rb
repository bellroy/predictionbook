class AddPredictionGroupToPredictions < ActiveRecord::Migration[4.2]
  def change
    add_reference :predictions, :prediction_group, index: true, foreign_key: true
  end
end
