# frozen_string_literal: true

module Mutations
  class BlockTeeTimes < BaseMutation
    argument :course_id, ID, required: true
    argument :block_type, Types::BlockTypeEnum, required: true
    argument :reason, String, required: true
    argument :description, String, required: false
    argument :starts_at, GraphQL::Types::ISO8601DateTime, required: true
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: true

    field :tee_time_block, Types::TeeTimeBlockType, null: true
    field :affected_count, Integer, null: false
    field :errors, [String], null: false

    def resolve(course_id:, **args)
      org = require_auth!
      require_role!(:staff)

      course = Course.find_by(id: course_id, organization_id: org.id)
      raise GraphQL::ExecutionError, "Course not found" unless course

      result = TeeSheets::BlockTeeTimesService.call(
        organization: org,
        course: course,
        user: current_user,
        **args
      )

      if result.success?
        {
          tee_time_block: result.data.block,
          affected_count: result.data.affected_count,
          errors: []
        }
      else
        { tee_time_block: nil, affected_count: 0, errors: result.errors }
      end
    end
  end
end
