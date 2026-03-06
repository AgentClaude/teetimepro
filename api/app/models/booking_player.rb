class BookingPlayer < ApplicationRecord
  belongs_to :booking
  belongs_to :golfer_profile, optional: true

  validates :name, presence: true

  def handicap
    golfer_profile&.handicap_index
  end
end
