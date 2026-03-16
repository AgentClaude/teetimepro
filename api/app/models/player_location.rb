class PlayerLocation < ApplicationRecord
  belongs_to :booking
  belongs_to :course
  belongs_to :rangefinder_device, optional: true

  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :recorded_at, presence: true
  validates :current_hole, numericality: { in: 1..36 }, allow_nil: true
  validates :accuracy_meters, numericality: { greater_than: 0 }, allow_nil: true

  scope :recent, -> { where("recorded_at > ?", 1.hour.ago).order(recorded_at: :desc) }
  scope :for_hole, ->(hole) { where(current_hole: hole) }

  def coordinates
    { latitude: latitude, longitude: longitude }
  end

  def distances_to_features
    features = course.course_holes
      .where(hole_number: current_hole)
      .flat_map(&:gps_features)

    features.map do |feature|
      {
        feature: feature,
        distance_yards: feature.distance_to(latitude, longitude)
      }
    end.sort_by { |d| d[:distance_yards] }
  end
end
