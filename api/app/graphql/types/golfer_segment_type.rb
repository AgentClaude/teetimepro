# frozen_string_literal: true

module Types
  class GolferSegmentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :filter_criteria, GraphQL::Types::JSON, null: false
    field :is_dynamic, Boolean, null: false
    field :cached_count, Integer, null: false
    field :last_evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_by, Types::UserType, null: false
    field :members, [Types::UserType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def members
      if object.is_dynamic
        result = Segments::EvaluateService.call(
          organization: object.organization,
          filter_criteria: object.filter_criteria
        )
        result.success? ? result.users.limit(100) : []
      else
        object.members.limit(100)
      end
    end
  end
end
