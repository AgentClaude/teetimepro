module Gps
  class CreateCourseGpsFeatureService < ApplicationService
    attr_accessor :course_hole, :feature_type, :name, :latitude, :longitude,
                  :elevation_feet, :distance_from_tee_yards, :metadata

    validates :course_hole, :feature_type, :name, :latitude, :longitude, presence: true

    def call
      return validation_failure(self) unless valid?

      feature = CourseGpsFeature.new(
        course_hole: course_hole,
        feature_type: feature_type,
        name: name,
        latitude: latitude,
        longitude: longitude,
        elevation_feet: elevation_feet,
        distance_from_tee_yards: distance_from_tee_yards,
        metadata: metadata || {}
      )

      if feature.save
        success(gps_feature: feature)
      else
        failure(feature.errors.full_messages)
      end
    end
  end
end
