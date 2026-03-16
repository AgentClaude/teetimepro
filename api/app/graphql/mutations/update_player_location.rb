module Mutations
  class UpdatePlayerLocation < BaseMutation
    argument :booking_id, ID, required: true
    argument :latitude, Float, required: true
    argument :longitude, Float, required: true
    argument :accuracy_meters, Float, required: false
    argument :current_hole, Integer, required: false
    argument :rangefinder_device_id, ID, required: false

    field :player_location, Types::PlayerLocationType, null: true
    field :distances, [Types::DistanceMeasurementType], null: false
    field :errors, [String], null: false

    def resolve(booking_id:, latitude:, longitude:, accuracy_meters: nil, current_hole: nil, rangefinder_device_id: nil)
      require_auth!

      booking = Booking.joins(tee_time: { tee_sheet: :course })
        .where(courses: { organization_id: current_organization.id })
        .find(booking_id)

      device = if rangefinder_device_id
        RangefinderDevice.where(organization: current_organization).find(rangefinder_device_id)
      end

      result = Gps::UpdatePlayerLocationService.call(
        booking: booking,
        latitude: latitude,
        longitude: longitude,
        accuracy_meters: accuracy_meters,
        current_hole: current_hole,
        rangefinder_device: device
      )

      if result.success?
        {
          player_location: result.data[:player_location],
          distances: result.data[:distances] || [],
          errors: []
        }
      else
        { player_location: nil, distances: [], errors: result.errors }
      end
    end
  end
end
