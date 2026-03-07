class TournamentScore < ApplicationRecord
  belongs_to :tournament_round
  belongs_to :tournament_entry

  validates :hole_number, presence: true,
                          numericality: { greater_than: 0, less_than_or_equal_to: 18 },
                          uniqueness: { scope: [:tournament_round_id, :tournament_entry_id] }
  validates :strokes, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validates :par, presence: true, numericality: { in: 3..5 }
  validates :putts, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :for_entry, ->(entry) { where(tournament_entry: entry) }
  scope :for_round, ->(round) { where(tournament_round: round) }
  scope :by_hole, -> { order(:hole_number) }

  delegate :tournament, to: :tournament_round
  delegate :user, to: :tournament_entry

  def score_to_par
    strokes - par
  end

  def eagle_or_better?
    score_to_par <= -2
  end

  def birdie?
    score_to_par == -1
  end

  def par_score?
    score_to_par == 0
  end

  def bogey?
    score_to_par == 1
  end

  def double_bogey_or_worse?
    score_to_par >= 2
  end

  def score_label
    case score_to_par
    when ..-3 then "albatross"
    when -2 then "eagle"
    when -1 then "birdie"
    when 0 then "par"
    when 1 then "bogey"
    when 2 then "double_bogey"
    else "triple_bogey_plus"
    end
  end
end
