class PredictionGroupSerializer < ActiveModel::Serializer
  attributes :id, :description

  has_many :predictions
end
