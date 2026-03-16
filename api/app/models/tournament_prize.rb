class TournamentPrize < ApplicationRecord
  belongs_to :tournament
  belongs_to :awarded_to, class_name: "TournamentEntry", optional: true

  enum :prize_type, { cash: 0, voucher: 1, trophy: 2, merchandise: 3, custom: 4 }

  monetize :amount_cents

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :position, uniqueness: { scope: :tournament_id, message: "already exists for this tournament" }
  validates :description, presence: true
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :prize_type, presence: true

  scope :for_tournament, ->(tournament) { where(tournament: tournament) }
  scope :by_position, -> { order(:position) }
  scope :awarded, -> { where.not(awarded_to: nil) }
  scope :unawarded, -> { where(awarded_to: nil) }

  delegate :organization, to: :tournament

  def awarded?
    awarded_to.present?
  end

  def cash_prize?
    cash?
  end

  def amount
    Money.new(amount_cents, 'USD')
  end
end