class Course < ApplicationRecord
  belongs_to :organization
  has_many :tee_sheets, dependent: :destroy
  has_many :tee_times, through: :tee_sheets
  has_many :bookings, through: :tee_times
  has_many :voice_call_logs, dependent: :nullify
  has_many :tournaments, dependent: :destroy

  validates :name, presence: true
  validates :holes, inclusion: { in: [9, 18, 27, 36] }
  validates :interval_minutes, inclusion: { in: [7, 8, 9, 10, 12, 15] }
  validates :first_tee_time, presence: true
  validates :last_tee_time, presence: true
  validates :max_players_per_slot, presence: true, numericality: { in: 1..5 }

  monetize :weekday_rate_cents, allow_nil: true
  monetize :weekend_rate_cents, allow_nil: true
  monetize :twilight_rate_cents, allow_nil: true

  def weekend?(date)
    date.saturday? || date.sunday?
  end

  def default_rate_for(date, time)
    if twilight_time?(time)
      twilight_rate
    elsif weekend?(date)
      weekend_rate
    else
      weekday_rate
    end
  end

  def twilight_time?(time)
    return false unless respond_to?(:twilight_start_time) && twilight_start_time.present?

    time >= twilight_start_time
  end
end
