module Types
  class PlayerLocationType < BaseObject
    description "A player's GPS location on the course"

    field :id, ID, null: false
    field :latitude, Float, null: false
    field :longitude, Float, null: false
    field :accuracy_meters, Float, null: true
    field :current_hole, Integer, null: true
    field :recorded_at, GraphQL::Types::ISO8601DateTime, null: false
    field :booking, Types::BookingType, null: false
    field :rangefinder_device, Types::RangefinderDeviceObjectType, null: true
  end
end
