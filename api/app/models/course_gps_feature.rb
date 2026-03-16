class CourseGpsFeature < ApplicationRecord
  belongs_to :course_hole

  has_one :course, through: :course_hole

  enum :feature_type, {
    tee_box: 0,
    green_center: 1,
    green_front: 2,
    green_back: 3,
    bunker: 4,
    water_hazard: 5,
    fairway_center: 6,
    dogleg: 7,
    layup: 8,
    pin_position: 9,
    tree_line: 10,
    out_of_bounds: 11
  }

  validates :name, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :feature_type, presence: true
  validates :distance_from_tee_yards, numericality: { greater_than: 0 }, allow_nil: true
  validates :elevation_feet, numericality: true, allow_nil: true

  scope :for_hole, ->(hole_number) { joins(:course_hole).where(course_holes: { hole_number: hole_number }) }
  scope :hazards, -> { where(feature_type: [:bunker, :water_hazard, :out_of_bounds]) }
  scope :targets, -> { where(feature_type: [:green_center, :green_front, :green_back, :pin_position, :fairway_center, :layup]) }

  def coordinates
    { latitude: latitude, longitude: longitude }
  end

  def distance_to(lat, lng)
    Gps::CalculateDistanceService.haversine_yards(latitude, longitude, lat, lng)
  end
end
