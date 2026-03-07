module Mutations
  class CreateBooking < BaseMutation
    argument :tee_time_id, ID, required: true
    argument :players_count, Integer, required: true
    argument :payment_method_id, String, required: false
    argument :player_names, [String], required: false,
             description: "Legacy: simple player name list"
    argument :player_details, [Types::PlayerDetailInput], required: false,
             description: "Player details including name, email, phone"
    argument :loyalty_redemption_code, String, required: false,
             description: "Loyalty reward redemption code to apply"

    field :booking, Types::BookingType, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:, players_count:, payment_method_id: nil,
                player_names: nil, player_details: nil, loyalty_redemption_code: nil)
      org = require_auth!
      tee_time = TeeTime.joins(tee_sheet: :course)
                        .where(courses: { organization_id: org.id })
                        .find(tee_time_id)

      # Convert player_details to the format the service expects
      resolved_player_details = nil
      if player_details.present?
        resolved_player_details = player_details.map do |pd|
          { name: pd.name, email: pd.email, phone: pd.phone }
        end
      end

      result = Bookings::CreateBookingService.call(
        organization: org,
        tee_time: tee_time,
        user: current_user,
        players_count: players_count,
        payment_method_id: payment_method_id,
        player_names: player_names,
        player_details: resolved_player_details,
        loyalty_redemption_code: loyalty_redemption_code
      )

      if result.success?
        { booking: result.data.booking, errors: [] }
      else
        { booking: nil, errors: result.errors }
      end
    end
  end
end
