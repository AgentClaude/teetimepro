module Mutations
  class UpdateTeeTime < BaseMutation
    argument :tee_time_id, ID, required: true
    argument :status, String, required: false
    argument :price_cents, Integer, required: false
    argument :notes, String, required: false
    argument :max_players, Integer, required: false

    field :tee_time, Types::TeeTimeType, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:, **args)
      org = require_auth!
      require_role!(:staff)

      tee_time = TeeTime.joins(tee_sheet: :course)
                        .where(courses: { organization_id: org.id })
                        .find(tee_time_id)

      result = TeeSheets::UpdateTeeTimeService.call(
        tee_time: tee_time,
        status: args[:status],
        price_cents: args[:price_cents],
        notes: args[:notes],
        max_players: args[:max_players]
      )

      if result.success?
        { tee_time: result.data.tee_time, errors: [] }
      else
        { tee_time: nil, errors: result.errors }
      end
    end
  end
end
