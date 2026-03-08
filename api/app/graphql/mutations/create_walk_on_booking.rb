module Mutations
  class CreateWalkOnBooking < BaseMutation
    description "Create a walk-on booking for a guest who arrives without a reservation. Requires pro_shop role or above."

    argument :tee_time_id, ID, required: false,
             description: "Specific tee time to book. If omitted, finds next available slot."
    argument :course_id, ID, required: false,
             description: "Course to find next available slot on (used when tee_time_id is not provided)"
    argument :players_count, Integer, required: true
    argument :guest_name, String, required: true,
             description: "Name of the walk-on guest"
    argument :guest_email, String, required: false
    argument :guest_phone, String, required: false
    argument :walk_on_notes, String, required: false,
             description: "Staff notes about the walk-on (e.g. equipment rental, special requests)"
    argument :user_id, ID, required: false,
             description: "Existing user ID if the guest has an account"

    field :booking, Types::BookingType, null: true
    field :tee_time, Types::TeeTimeType, null: true
    field :errors, [String], null: false

    def resolve(players_count:, guest_name:, tee_time_id: nil, course_id: nil,
                guest_email: nil, guest_phone: nil, walk_on_notes: nil, user_id: nil)
      org = require_auth!
      require_role!(:pro_shop)

      result = Bookings::CreateWalkOnBookingService.call(
        organization: org,
        staff_user: current_user,
        tee_time_id: tee_time_id,
        course_id: course_id,
        players_count: players_count,
        guest_name: guest_name,
        guest_email: guest_email,
        guest_phone: guest_phone,
        walk_on_notes: walk_on_notes,
        user_id: user_id
      )

      if result.success?
        {
          booking: result.data.booking,
          tee_time: result.data.tee_time,
          errors: []
        }
      else
        { booking: nil, tee_time: nil, errors: result.errors }
      end
    end
  end
end
