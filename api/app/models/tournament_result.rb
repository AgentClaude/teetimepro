class TournamentResult < ApplicationRecord
  belongs_to :tournament
  belongs_to :tournament_entry
  has_one :user, through: :tournament_entry
  has_one :tournament_prize, through: :tournament_entry, source: :tournament_prizes

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :total_strokes, presence: true, numericality: { greater_than: 0 }
  validates :total_to_par, presence: true
  validates :tournament_entry_id, uniqueness: { scope: :tournament_id, message: "already has a result for this tournament" }
  
  # Position can be duplicated only if tied is true
  validates :position, uniqueness: { 
    scope: [:tournament_id, :tied], 
    message: "already exists for this tournament unless tied",
    unless: :tied?
  }

  scope :for_tournament, ->(tournament) { where(tournament: tournament) }
  scope :podium, -> { where(position: 1..3) }
  scope :by_position, -> { order(:position, :total_to_par, :total_strokes) }
  scope :finalized, -> { where.not(finalized_at: nil) }

  delegate :organization, to: :tournament
  delegate :user, to: :tournament_entry
  delegate :full_name, to: :user, prefix: :player

  def finalized?
    finalized_at.present?
  end

  def prize_eligible?
    !tied? || position <= 3
  end

  def format_position
    tied? ? "T#{position}" : position.to_s
  end

  def format_to_par
    return "E" if total_to_par == 0
    return "+#{total_to_par}" if total_to_par > 0
    total_to_par.to_s
  end
end