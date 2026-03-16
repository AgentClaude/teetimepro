module Types
  class RecentActivityType < Types::BaseObject
    field :id, ID, null: false
    field :activity_type, String, null: false
    field :confirmation_code, String, null: false
    field :user_name, String, null: false
    field :course_name, String, null: false
    field :tee_time, GraphQL::Types::ISO8601DateTime, null: false
    field :players_count, Integer, null: false
    field :occurred_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end