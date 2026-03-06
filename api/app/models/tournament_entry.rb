class TournamentEntry < ApplicationRecord
  belongs_to :tournament
  belongs_to :user
  belongs_to :payment, optional: true

  enum :status, { registered: 0, confirmed: 1, withdrawn: 2, disqualified: 3 }

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :tournament_id, message: "is already registered for this tournament" }
  validates :handicap_index, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :handicap_within_tournament_limit
  validate :tournament_accepts_registrations, on: :create

  scope :active, -> { where.not(status: :withdrawn) }

  delegate :organization, to: :tournament

  def withdraw!
    return false if withdrawn? || disqualified?

    update!(status: :withdrawn)
  end

  private

  def handicap_within_tournament_limit
    return unless handicap_index && tournament&.max_handicap

    if handicap_index > tournament.max_handicap
      errors.add(:handicap_index, "exceeds tournament maximum of #{tournament.max_handicap}")
    end
  end

  def tournament_accepts_registrations
    return unless tournament

    unless tournament.registration_available?
      errors.add(:base, "Tournament is not accepting registrations")
    end
  end
end
