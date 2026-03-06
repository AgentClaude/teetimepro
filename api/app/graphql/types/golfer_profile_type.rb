module Types
  class GolferProfileType < Types::BaseObject
    field :id, ID, null: false
    field :handicap_index, Float, null: true
    field :home_course, String, null: true
    field :preferred_tee, String, null: true
    field :user, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
