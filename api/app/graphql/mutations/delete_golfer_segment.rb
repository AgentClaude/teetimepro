# frozen_string_literal: true

module Mutations
  class DeleteGolferSegment < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      org = require_auth!
      require_role!(:manager)

      segment = org.golfer_segments.find(id)

      result = Segments::DeleteService.call(
        segment: segment,
        user: context[:current_user]
      )

      if result.success?
        { success: true, errors: [] }
      else
        { success: false, errors: result.errors }
      end
    end
  end
end
