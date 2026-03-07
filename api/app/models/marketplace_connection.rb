class MarketplaceConnection < ApplicationRecord
  belongs_to :organization
  belongs_to :course
  has_many :marketplace_listings, dependent: :destroy

  PROVIDERS = %w[golfnow teeoff].freeze

  enum :status, { pending: 0, active: 1, paused: 2, error: 3 }

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :provider, uniqueness: { scope: [:organization_id, :course_id],
                                      message: "already connected for this course" }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :syncable, -> { where(status: :active) }

  # Default syndication settings
  DEFAULT_SETTINGS = {
    "auto_syndicate" => true,
    "min_advance_hours" => 4,       # Don't list tee times less than 4h away
    "max_advance_days" => 14,       # List up to 14 days out
    "discount_percent" => 0,        # Discount off rack rate for marketplace
    "blocked_time_ranges" => [],    # Time ranges to exclude from syndication
    "min_available_spots" => 1      # Minimum spots to syndicate
  }.freeze

  def effective_settings
    DEFAULT_SETTINGS.merge(settings || {})
  end

  def provider_label
    case provider
    when "golfnow" then "GolfNow"
    when "teeoff" then "TeeOff"
    else provider.titleize
    end
  end

  def syndicatable_tee_times
    s = effective_settings
    min_time = Time.current + s["min_advance_hours"].to_i.hours
    max_time = Time.current + s["max_advance_days"].to_i.days

    course.tee_sheets
          .joins(:tee_times)
          .merge(
            TeeTime.where(status: [:available, :partially_booked])
                   .where(starts_at: min_time..max_time)
                   .where("max_players - booked_players >= ?", s["min_available_spots"].to_i)
          )
          .select("tee_times.*")
  end

  def record_sync!
    update!(last_synced_at: Time.current, last_error: nil)
  end

  def record_error!(message)
    update!(last_error: message, status: :error)
  end
end
