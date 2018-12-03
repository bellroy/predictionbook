# frozen_string_literal: true

class ResponseSerializer < ActiveModel::Serializer
  attributes :id, :confidence, :created_at, :updated_at, :user_id, :comment
end
