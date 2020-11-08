# frozen_string_literal: true

class ResponseSerializer < ActiveModel::Serializer
  attributes :comment,
             :confidence,
             :created_at,
             :id,
             :updated_at,
             :user_id,
             :user_label

  def user_label
    object.user.to_s
  end
end
