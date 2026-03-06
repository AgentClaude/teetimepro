module Mutations
  class UpdateBooking < BaseMutation
    argument :id, ID, required: true
    argument :status, String, required: false
    argument :players_count, Integer, required: false
    argument :notes, String, required: false

    field :booking, Types::BookingType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attrs)
      require_auth!
      require_role!(:manager)

      booking = Booking.for_organization(current_organization).find(id)
      updates = attrs.compact

      if booking.update(updates)
        { booking: booking, errors: [] }
      else
        { booking: nil, errors: booking.errors.full_messages }
      end
    end
  end
end
