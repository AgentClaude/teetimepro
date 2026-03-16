module Gps
  class GetHoleOverviewService < ApplicationService
    attr_accessor :course, :hole_number, :player_latitude, :player_longitude

    validates :course, :hole_number, presence: true

    def call
      return validation_failure(self) unless valid?

      course_hole = course.course_holes.find_by(hole_number: hole_number)
      return failure(["Hole #{hole_number} not found"]) unless course_hole

      features = course_hole.gps_features.order(:feature_type)

      overview = {
        hole_number: hole_number,
        par: course_hole.par,
        yardage: course_hole.yardage,
        features: features.map { |f| feature_data(f) }
      }

      if player_latitude.present? && player_longitude.present?
        overview[:distances] = features.map do |feature|
          {
            feature_id: feature.id,
            feature_name: feature.name,
            feature_type: feature.feature_type,
            distance_yards: feature.distance_to(player_latitude, player_longitude).round(1)
          }
        end.sort_by { |d| d[:distance_yards] }
      end

      success(overview: overview)
    end

    private

    def feature_data(feature)
      {
        id: feature.id,
        name: feature.name,
        feature_type: feature.feature_type,
        latitude: feature.latitude,
        longitude: feature.longitude,
        elevation_feet: feature.elevation_feet,
        distance_from_tee_yards: feature.distance_from_tee_yards
      }
    end
  end
end
