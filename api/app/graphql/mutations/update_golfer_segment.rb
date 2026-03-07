# frozen_string_literal: true

module Mutations
  class UpdateGolferSegment < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :filter_criteria, GraphQL::Types::JSON, required: false
    argument :is_dynamic, Boolean, required: false

    field :golfer_segment, Types::GolferSegmentType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attrs)
      org = require_auth!
      require_role!(:manager)

      segment = org.golfer_segments.find(id)

      result = Segments::UpdateService.call(
        segment: segment,
        user: context[:current_user],
        **attrs.compact
      )

      if result.success?
        { golfer_segment: result.segment, errors: [] }
      else
        { golfer_segment: nil, errors: result.errors }
      end
    end
  end
end
