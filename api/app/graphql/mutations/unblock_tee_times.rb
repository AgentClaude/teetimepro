# frozen_string_literal: true

module Mutations
  class UnblockTeeTimes < BaseMutation
    argument :tee_time_block_id, ID, required: true

    field :tee_time_block, Types::TeeTimeBlockType, null: true
    field :restored_count, Integer, null: false
    field :errors, [String], null: false

    def resolve(tee_time_block_id:)
      org = require_auth!
      require_role!(:staff)

      result = TeeSheets::UnblockTeeTimesService.call(
        organization: org,
        tee_time_block_id: tee_time_block_id,
        user: current_user
      )

      if result.success?
        {
          tee_time_block: result.data.block,
          restored_count: result.data.restored_count,
          errors: []
        }
      else
        { tee_time_block: nil, restored_count: 0, errors: result.errors }
      end
    end
  end
end
