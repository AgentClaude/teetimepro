module Mutations
  class CancelBooking < BaseMutation
    argument :booking_id, ID, required: true
    argument :reason, String, required: false
    argument :refund, Boolean, required: false

    field :booking, Types::BookingType, null: true
    field :errors, [String], null: false

    def resolve(booking_id:, reason: nil, refund: false)
      require_auth!

      booking = if current_user.can_manage_bookings?
                  Booking.for_organization(current_organization).find(booking_id)
                else
                  current_user.bookings.find(booking_id)
                end

      authorize(booking, :destroy?)

      result = Bookings::CancelBookingService.call(
        booking: booking,
        reason: reason,
        refund: refund
      )

      if result.success?
        { booking: result.data.booking, errors: [] }
      else
        { booking: nil, errors: result.errors }
      end
    end
  end
end
