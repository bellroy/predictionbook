# frozen_string_literal: true

class PredictionSerializer < ActiveModel::Serializer
  attributes :created_at,
             :creator_id,
             :creator_label,
             :deadline,
             :description_with_group,
             :description,
             :group_id,
             :id,
             :mean_confidence,
             :outcome,
             :prediction_group_id,
             :updated_at,
             :uuid,
             :version,
             :visibility,
             :withdrawn

  has_many :responses

  def creator_label
    object.creator.to_s
  end
end
