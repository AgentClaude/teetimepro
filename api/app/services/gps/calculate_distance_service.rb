module Gps
  class CalculateDistanceService < ApplicationService
    EARTH_RADIUS_YARDS = 6_975_817.98 # Earth's mean radius in yards

    attr_accessor :from_lat, :from_lng, :to_lat, :to_lng

    validates :from_lat, :from_lng, :to_lat, :to_lng, presence: true

    def call
      return validation_failure(self) unless valid?

      distance = self.class.haversine_yards(from_lat, from_lng, to_lat, to_lng)

      success(
        distance_yards: distance.round(1),
        distance_meters: (distance * 0.9144).round(1),
        distance_feet: (distance * 3).round(1)
      )
    end

    # Class-level utility for use without service instantiation
    def self.haversine_yards(lat1, lng1, lat2, lng2)
      lat1_rad = to_radians(lat1.to_f)
      lat2_rad = to_radians(lat2.to_f)
      delta_lat = to_radians(lat2.to_f - lat1.to_f)
      delta_lng = to_radians(lng2.to_f - lng1.to_f)

      a = Math.sin(delta_lat / 2)**2 +
          Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(delta_lng / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      EARTH_RADIUS_YARDS * c
    end

    def self.to_radians(degrees)
      degrees * Math::PI / 180.0
    end
  end
end
