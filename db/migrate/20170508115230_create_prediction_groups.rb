class CreatePredictionGroups < ActiveRecord::Migration
  def change
    create_table :prediction_groups do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
