class Round < ApplicationRecord
  belongs_to :golfer_profile
  belongs_to :course, optional: true

  validates :course_name, presence: true
  validates :played_on, presence: true
  validates :score, presence: true, numericality: { in: 18..200 }
  validates :holes_played, presence: true, inclusion: { in: [9, 18] }
  validates :course_rating, numericality: { in: 55.0..85.0 }, allow_nil: true
  validates :slope_rating, numericality: { in: 55..155 }, allow_nil: true
  validates :putts, numericality: { in: 0..100 }, allow_nil: true
  validates :fairways_hit, numericality: { in: 0..18 }, allow_nil: true
  validates :greens_in_regulation, numericality: { in: 0..18 }, allow_nil: true

  before_save :calculate_differential
  after_save :update_profile_stats
  after_destroy :update_profile_stats

  scope :recent, -> { order(played_on: :desc) }
  scope :for_handicap, -> { where(holes_played: 18).where.not(course_rating: nil, slope_rating: nil) }
  scope :last_n, ->(n) { recent.limit(n) }

  def calculate_differential
    return unless course_rating.present? && slope_rating.present?

    self.differential = ((113.0 / slope_rating) * (score - course_rating)).round(1)
  end

  private

  def update_profile_stats
    golfer_profile.recalculate_stats!
  end
end
