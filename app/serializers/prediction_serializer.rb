class PredictionSerializer < ActiveModel::Serializer
  attributes :id, :description, :deadline, :created_at, :updated_at, :creator_id, :uuid,
             :withdrawn, :version, :visibility, :group_id, :prediction_group_id, :outcome,
             :mean_confidence

  has_many :responses
end
