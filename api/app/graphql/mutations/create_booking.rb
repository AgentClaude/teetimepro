module Mutations
  class CreateBooking < BaseMutation
    argument :tee_time_id, ID, required: true
    argument :players_count, Integer, required: true
    argument :payment_method_id, String, required: false
    argument :player_names, [String], required: false

    field :booking, Types::BookingType, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:, players_count:, payment_method_id: nil, player_names: nil)
      org = require_auth!
      tee_time = TeeTime.joins(tee_sheet: :course)
                        .where(courses: { organization_id: org.id })
                        .find(tee_time_id)

      result = Bookings::CreateBookingService.call(
        organization: org,
        tee_time: tee_time,
        user: current_user,
        players_count: players_count,
        payment_method_id: payment_method_id,
        player_names: player_names
      )

      if result.success?
        { booking: result.data.booking, errors: [] }
      else
        { booking: nil, errors: result.errors }
      end
    end
  end
end
