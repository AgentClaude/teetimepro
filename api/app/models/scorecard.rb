class Scorecard < ApplicationRecord
  belongs_to :golfer_profile
  belongs_to :course
  belongs_to :booking, optional: true
  belongs_to :round, optional: true

  has_many :hole_scores, -> { order(:hole_number) }, dependent: :destroy

  validates :played_on, presence: true
  validates :holes_played, presence: true, inclusion: { in: [9, 18] }
  validates :status, presence: true, inclusion: { in: %w[in_progress completed abandoned] }
  validates :tee_color, length: { maximum: 50 }, allow_nil: true
  validates :course_rating, numericality: { in: 55.0..85.0 }, allow_nil: true
  validates :slope_rating, numericality: { in: 55..155 }, allow_nil: true

  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :recent, -> { order(played_on: :desc, created_at: :desc) }
  scope :for_golfer, ->(golfer_profile_id) { where(golfer_profile_id: golfer_profile_id) }

  def in_progress?
    status == "in_progress"
  end

  def completed?
    status == "completed"
  end

  def abandoned?
    status == "abandoned"
  end

  def holes_completed
    hole_scores.where.not(strokes: nil).count
  end

  def recalculate_totals!
    scored_holes = hole_scores.where.not(strokes: nil)
    return if scored_holes.empty?

    self.total_strokes = scored_holes.sum(:strokes)
    self.total_putts = scored_holes.where.not(putts: nil).sum(:putts)
    self.total_fairways_hit = scored_holes.where(fairway_hit: true).count
    self.total_greens_in_regulation = scored_holes.where(green_in_regulation: true).count
    self.total_penalties = scored_holes.sum(:penalties)

    total_par = scored_holes.sum(:par)
    self.score_to_par = total_strokes - total_par

    front = scored_holes.where(hole_number: 1..9)
    back = scored_holes.where(hole_number: 10..18)
    self.front_nine_strokes = front.any? ? front.sum(:strokes) : nil
    self.back_nine_strokes = back.any? ? back.sum(:strokes) : nil

    save!
  end
end
