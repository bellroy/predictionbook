class AddPredictionGroupToPredictions < ActiveRecord::Migration
  def change
    add_reference :predictions, :prediction_group, index: true, foreign_key: true
  end
end
