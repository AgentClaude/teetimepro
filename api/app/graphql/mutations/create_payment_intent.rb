module Mutations
  class CreatePaymentIntent < BaseMutation
    argument :tee_time_id, ID, required: true
    argument :players_count, Integer, required: true

    field :client_secret, String, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:, players_count:)
      org = require_auth!
      tee_time = TeeTime.joins(tee_sheet: :course)
                        .where(courses: { organization_id: org.id })
                        .find(tee_time_id)

      result = Payments::CreatePaymentIntentService.call(
        organization: org,
        tee_time: tee_time,
        user: current_user,
        players_count: players_count
      )

      if result.success?
        { client_secret: result.data.client_secret, errors: [] }
      else
        { client_secret: nil, errors: result.errors }
      end
    end
  end
end