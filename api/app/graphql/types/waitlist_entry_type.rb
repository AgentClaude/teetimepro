# frozen_string_literal: true

module Types
  class WaitlistEntryType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :tee_time, Types::TeeTimeType, null: false
    field :players_requested, Integer, null: false
    field :status, String, null: false
    field :notified_at, GraphQL::Types::ISO8601DateTime, null: true
    field :expired_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
