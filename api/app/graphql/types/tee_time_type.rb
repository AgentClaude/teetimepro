module Types
  class TeeTimeType < Types::BaseObject
    field :id, ID, null: false
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :formatted_time, String, null: false
    field :status, String, null: false
    field :max_players, Integer, null: false
    field :booked_players, Integer, null: false
    field :available_spots, Integer, null: false
    field :price_cents, Integer, null: true
    field :notes, String, null: true
    field :tee_sheet_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :bookings, [Types::BookingType], null: false

    def bookings
      object.bookings.where.not(status: :cancelled)
    end
  end
end
