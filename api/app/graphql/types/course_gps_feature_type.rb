module Types
  class CourseGpsFeatureType < BaseObject
    description "GPS coordinate feature on a golf course hole"

    field :id, ID, null: false
    field :name, String, null: false
    field :feature_type, GpsFeatureTypeEnum, null: false
    field :latitude, Float, null: false
    field :longitude, Float, null: false
    field :elevation_feet, Float, null: true
    field :distance_from_tee_yards, Integer, null: true
    field :metadata, GraphQL::Types::JSON, null: false
    field :course_hole, Types::CourseHoleType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
