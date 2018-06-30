class UserSerializer < ActiveModel::Serializer
  attributes :id, :login, :name, :created_at, :updated_at
end
