class Course < ApplicationRecord
  belongs_to :organization
  has_many :tee_sheets, dependent: :destroy
  has_many :tee_times, through: :tee_sheets
  has_many :bookings, through: :tee_times
  has_many :voice_call_logs, dependent: :nullify
  has_many :tournaments, dependent: :destroy
  has_many :pricing_rules, dependent: :destroy
  has_many :marketplace_connections, dependent: :destroy
  has_many :marketplace_listings, through: :marketplace_connections
  has_many :course_holes, -> { order(:hole_number) }, dependent: :destroy
  has_many :scorecards, dependent: :destroy
  has_many :course_gps_features, through: :course_holes, source: :gps_features
  has_many :player_locations, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :holes, inclusion: { in: [9, 18, 27, 36] }
  validates :interval_minutes, inclusion: { in: [7, 8, 9, 10, 12, 15] }
  validates :first_tee_time, presence: true
  validates :last_tee_time, presence: true
  validates :max_players_per_slot, presence: true, numericality: { in: 1..5 }

  before_validation :generate_slug, on: :create

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
    # Default twilight start time to 3 PM if not set
    start_time = if respond_to?(:twilight_start_time) && twilight_start_time.present?
      twilight_start_time
    else
      Time.zone.parse("15:00")
    end

    time.hour * 60 + time.min >= start_time.hour * 60 + start_time.min
  end

  private

  def generate_slug
    return if slug.present?
    
    base_slug = name.parameterize
    candidate_slug = base_slug
    counter = 1
    
    while Course.exists?(slug: candidate_slug)
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = candidate_slug
  end
end
