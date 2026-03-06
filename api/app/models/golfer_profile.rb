class GolferProfile < ApplicationRecord
  belongs_to :user
  has_many :booking_players, dependent: :nullify

  validates :handicap_index, numericality: { in: -10.0..54.0 }, allow_nil: true

  def display_handicap
    return "N/A" unless handicap_index

    handicap_index.positive? ? "+#{handicap_index}" : handicap_index.to_s
  end
end
