module Gps
  class UpdatePlayerLocationService < ApplicationService
    attr_accessor :booking, :latitude, :longitude, :accuracy_meters,
                  :current_hole, :rangefinder_device

    validates :booking, :latitude, :longitude, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Booking is not active"]) unless booking.confirmed? || booking.checked_in?

      location = PlayerLocation.create!(
        booking: booking,
        course: booking.tee_time.tee_sheet.course,
        rangefinder_device: rangefinder_device,
        latitude: latitude,
        longitude: longitude,
        accuracy_meters: accuracy_meters,
        current_hole: current_hole,
        recorded_at: Time.current
      )

      rangefinder_device&.touch_seen!

      distances = compute_distances(location)

      success(
        player_location: location,
        distances: distances
      )
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def compute_distances(location)
      return [] unless location.current_hole.present?

      course = location.course
      features = CourseGpsFeature
        .joins(:course_hole)
        .where(course_holes: { course_id: course.id, hole_number: location.current_hole })
        .targets

      features.map do |feature|
        yards = feature.distance_to(location.latitude, location.longitude)
        {
          feature_id: feature.id,
          feature_name: feature.name,
          feature_type: feature.feature_type,
          distance_yards: yards.round(1)
        }
      end.sort_by { |d| d[:distance_yards] }
    end
  end
end
