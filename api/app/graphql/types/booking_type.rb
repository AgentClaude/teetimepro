module Types
  class BookingType < Types::BaseObject
    field :id, ID, null: false
    field :confirmation_code, String, null: false
    field :status, String, null: false
    field :players_count, Integer, null: false
    field :total_cents, Integer, null: false
    field :notes, String, null: true
    field :cancellable, Boolean, null: false
    field :cancelled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :cancellation_reason, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tee_time, Types::TeeTimeType, null: false
    field :user, Types::UserType, null: false
    field :booking_players, [Types::BookingPlayerType], null: false

    def cancellable
      object.cancellable?
    end
  end

  class BookingPlayerType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :handicap, Float, null: true
  end
end
