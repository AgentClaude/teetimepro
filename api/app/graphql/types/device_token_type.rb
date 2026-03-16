# frozen_string_literal: true

module Types
  class DeviceTokenType < Types::BaseObject
    field :id, ID, null: false
    field :platform, String, null: false
    field :device_id, String, null: true
    field :active, Boolean, null: false
    field :last_used_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
