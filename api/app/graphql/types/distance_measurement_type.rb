module Types
  class DistanceMeasurementType < BaseObject
    description "Distance measurement from player to a course feature"

    field :feature_id, ID, null: false
    field :feature_name, String, null: false
    field :feature_type, GpsFeatureTypeEnum, null: false
    field :distance_yards, Float, null: false
  end
end
