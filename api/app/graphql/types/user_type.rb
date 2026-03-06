module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :role, String, null: false
    field :organization_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :bookings, [Types::BookingType], null: false
    field :upcoming_bookings, [Types::BookingType], null: false
    field :golfer_profile, Types::GolferProfileType, null: true

    def upcoming_bookings
      object.bookings.upcoming.includes(tee_time: { tee_sheet: :course })
    end
  end
end
