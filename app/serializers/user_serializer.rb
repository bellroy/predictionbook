class UserSerializer < ActiveModel::Serializer
  attributes :email, :id, :login, :name, :created_at, :updated_at
end
