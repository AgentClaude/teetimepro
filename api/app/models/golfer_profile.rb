class GolferProfile < ApplicationRecord
  belongs_to :user
  has_many :booking_players, dependent: :nullify
  has_many :rounds, dependent: :destroy
  has_many :handicap_revisions, dependent: :destroy

  validates :handicap_index, numericality: { in: -10.0..54.0 }, allow_nil: true

  scope :with_stats, -> { select("golfer_profiles.*, (SELECT COUNT(*) FROM rounds WHERE rounds.golfer_profile_id = golfer_profiles.id) as rounds_count") }

  def display_handicap
    return "N/A" unless handicap_index

    handicap_index.positive? ? "+#{handicap_index}" : handicap_index.to_s
  end

  def recalculate_stats!
    profile_rounds = rounds.reload
    update!(
      total_rounds: profile_rounds.count,
      best_score: profile_rounds.where(holes_played: 18).minimum(:score),
      average_score: profile_rounds.where(holes_played: 18).average(:score)&.round(1),
      last_played_on: profile_rounds.maximum(:played_on)
    )
  end

  def handicap_eligible_rounds
    rounds.for_handicap.recent.limit(20)
  end

  def play_history(limit: 20, offset: 0)
    rounds.recent.offset(offset).limit(limit)
  end

  def handicap_trend(months: 12)
    handicap_revisions
      .where("effective_date >= ?", months.months.ago.to_date)
      .recent
  end
end
