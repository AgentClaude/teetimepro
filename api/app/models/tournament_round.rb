class TournamentRound < ApplicationRecord
  belongs_to :tournament
  has_many :tournament_scores, dependent: :destroy

  enum :status, { not_started: 0, in_progress: 1, completed: 2 }

  validates :round_number, presence: true,
                           numericality: { greater_than: 0 },
                           uniqueness: { scope: :tournament_id }
  validates :play_date, presence: true
  validates :status, presence: true

  scope :for_tournament, ->(tournament) { where(tournament: tournament) }
  scope :chronological, -> { order(:round_number) }

  delegate :organization, to: :tournament
end
