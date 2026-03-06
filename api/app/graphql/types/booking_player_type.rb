module Types
  class BookingPlayerType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: true
    field :phone, String, null: true
    field :golfer_profile, Types::GolferProfileType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
