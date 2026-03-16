module Types
  class CourseHoleType < BaseObject
    description "Hole configuration for a course"

    field :id, ID, null: false
    field :hole_number, Integer, null: false
    field :par, Integer, null: false
    field :yardage, Integer, null: true
    field :handicap_index, Integer, null: true
    field :gps_features, [Types::CourseGpsFeatureType], null: false

    def gps_features
      object.gps_features.order(:feature_type)
    end
  end
end
