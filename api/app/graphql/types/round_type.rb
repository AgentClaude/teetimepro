module Types
  class RoundType < Types::BaseObject
    field :id, ID, null: false
    field :course_name, String, null: false
    field :played_on, GraphQL::Types::ISO8601Date, null: false
    field :score, Integer, null: false
    field :holes_played, Integer, null: false
    field :course_rating, Float, null: true
    field :slope_rating, Integer, null: true
    field :differential, Float, null: true
    field :tee_color, String, null: true
    field :notes, String, null: true
    field :putts, Integer, null: true
    field :fairways_hit, Integer, null: true
    field :greens_in_regulation, Integer, null: true
    field :course, Types::CourseType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
