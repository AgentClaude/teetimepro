class TeeTime < ApplicationRecord
  belongs_to :tee_sheet
  has_many :bookings, dependent: :destroy
  has_many :booking_players, through: :bookings

  enum :status, { available: 0, partially_booked: 1, fully_booked: 2, blocked: 3, maintenance: 4 }

  validates :starts_at, presence: true
  validates :max_players, presence: true, numericality: { in: 1..5 }

  monetize :price_cents, allow_nil: true

  scope :available_for, ->(players) {
    where(status: [:available, :partially_booked])
      .where("max_players - booked_players >= ?", players)
  }

  scope :for_time_range, ->(start_time, end_time) {
    where(starts_at: start_time..end_time)
  }

  delegate :course, to: :tee_sheet
  delegate :date, to: :tee_sheet

  def available_spots
    max_players - booked_players
  end

  def book_spots!(count)
    raise "Not enough spots available" if count > available_spots

    update!(
      booked_players: booked_players + count,
      status: (booked_players + count >= max_players) ? :fully_booked : :partially_booked
    )
  end

  def release_spots!(count)
    new_count = [booked_players - count, 0].max
    update!(
      booked_players: new_count,
      status: new_count.zero? ? :available : :partially_booked
    )
  end

  def formatted_time
    tz = course&.timezone || course&.organization&.timezone || "UTC"
    starts_at.in_time_zone(tz).strftime("%-I:%M %p")
  end
end
