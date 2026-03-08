# frozen_string_literal: true

module Types
  class TeeTimeBlockType < Types::BaseObject
    field :id, ID, null: false
    field :block_type, String, null: false
    field :reason, String, null: false
    field :description, String, null: true
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: false
    field :active, Boolean, null: false
    field :recurring, Boolean, null: false
    field :recurrence_pattern, String, null: true
    field :affected_tee_time_count, Integer, null: false
    field :duration_minutes, Integer, null: false
    field :currently_active, Boolean, null: false

    field :course, Types::CourseType, null: false
    field :created_by, Types::UserType, null: false
    field :tee_times, [Types::TeeTimeType], null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def currently_active
      object.currently_active?
    end
  end
end
