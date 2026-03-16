module Mutations
  class CreateCourseGpsFeature < BaseMutation
    argument :course_hole_id, ID, required: true
    argument :feature_type, Types::GpsFeatureTypeEnum, required: true
    argument :name, String, required: true
    argument :latitude, Float, required: true
    argument :longitude, Float, required: true
    argument :elevation_feet, Float, required: false
    argument :distance_from_tee_yards, Integer, required: false
    argument :metadata, GraphQL::Types::JSON, required: false

    field :gps_feature, Types::CourseGpsFeatureType, null: true
    field :errors, [String], null: false

    def resolve(course_hole_id:, feature_type:, name:, latitude:, longitude:, elevation_feet: nil, distance_from_tee_yards: nil, metadata: nil)
      require_auth!

      course_hole = CourseHole.joins(:course)
        .where(courses: { organization_id: current_organization.id })
        .find(course_hole_id)

      result = Gps::CreateCourseGpsFeatureService.call(
        course_hole: course_hole,
        feature_type: feature_type,
        name: name,
        latitude: latitude,
        longitude: longitude,
        elevation_feet: elevation_feet,
        distance_from_tee_yards: distance_from_tee_yards,
        metadata: metadata
      )

      if result.success?
        { gps_feature: result.data[:gps_feature], errors: [] }
      else
        { gps_feature: nil, errors: result.errors }
      end
    end
  end
end
