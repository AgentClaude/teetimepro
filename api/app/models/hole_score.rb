class HoleScore < ApplicationRecord
  belongs_to :scorecard

  validates :hole_number, presence: true, inclusion: { in: 1..18 },
            uniqueness: { scope: :scorecard_id, message: "already recorded for this scorecard" }
  validates :par, presence: true, inclusion: { in: 3..6 }
  validates :strokes, numericality: { in: 1..20 }, allow_nil: true
  validates :putts, numericality: { in: 0..10 }, allow_nil: true
  validates :penalties, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :calculate_score_to_par

  private

  def calculate_score_to_par
    self.score_to_par = strokes.present? ? strokes - par : nil
  end
end
