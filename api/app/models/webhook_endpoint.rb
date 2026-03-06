class WebhookEndpoint < ApplicationRecord
  belongs_to :organization
  has_many :webhook_events, dependent: :destroy

  validates :url, presence: true, format: { with: /\Ahttps:\/\//, message: "must be a valid HTTPS URL" }
  validates :secret, presence: true, length: { minimum: 32 }
  validates :events, presence: true
  validate :valid_event_types

  scope :active, -> { where(active: true) }
  scope :for_organization, ->(org) { where(organization: org) }
  scope :subscribed_to_event, ->(event_type) { where("events::jsonb @> ?", [event_type].to_json) }

  # Available event types
  AVAILABLE_EVENTS = [
    'booking.created',
    'booking.cancelled', 
    'booking.checked_in',
    'tee_time.updated',
    'payment.completed',
    'payment.refunded'
  ].freeze

  before_validation :ensure_secret
  before_validation :ensure_events_array

  def subscribed_to?(event_type)
    events.include?(event_type.to_s)
  end

  def recent_events(limit = 50)
    webhook_events.order(created_at: :desc).limit(limit)
  end

  def success_rate(days = 7)
    total = webhook_events.where(created_at: days.days.ago..).count
    return 0 if total.zero?

    successful = webhook_events.where(created_at: days.days.ago.., status: :delivered).count
    (successful.to_f / total * 100).round(2)
  end

  private

  def ensure_secret
    self.secret = SecureRandom.hex(32) if secret.blank?
  end

  def ensure_events_array
    self.events = [] if events.nil?
    self.events = Array(events).flatten.uniq
  end

  def valid_event_types
    return if events.blank?

    invalid_events = events - AVAILABLE_EVENTS
    if invalid_events.any?
      errors.add(:events, "contains invalid event types: #{invalid_events.join(', ')}")
    end
  end
end