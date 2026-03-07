# frozen_string_literal: true

module Mutations
  class CreateGolferSegment < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :filter_criteria, GraphQL::Types::JSON, required: true
    argument :is_dynamic, Boolean, required: false

    field :golfer_segment, Types::GolferSegmentType, null: true
    field :errors, [String], null: false

    def resolve(name:, filter_criteria:, description: nil, is_dynamic: nil)
      org = require_auth!
      require_role!(:manager)

      result = Segments::CreateService.call(
        organization: org,
        user: context[:current_user],
        name: name,
        description: description,
        filter_criteria: filter_criteria,
        is_dynamic: is_dynamic
      )

      if result.success?
        { golfer_segment: result.segment, errors: [] }
      else
        { golfer_segment: nil, errors: result.errors }
      end
    end
  end
end
