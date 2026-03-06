class WebhookEvent < ApplicationRecord
  belongs_to :webhook_endpoint

  validates :event_type, presence: true
  validates :payload, presence: true
  validates :status, presence: true
  validates :attempts, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum :status, { pending: 0, delivered: 1, failed: 2 }

  scope :for_organization, ->(org) { joins(:webhook_endpoint).where(webhook_endpoints: { organization: org }) }
  scope :recent, -> { order(created_at: :desc) }
  scope :pending_retry, -> { where(status: :pending).where('attempts < ?', 5) }
  scope :recent_failures, -> { where(status: :failed, created_at: 1.hour.ago..) }

  # Check if event should be retried
  def should_retry?
    pending? && attempts < 5
  end

  # Calculate next retry delay using exponential backoff
  def next_retry_delay
    return 0 unless should_retry?

    # Base delay of 30 seconds with exponential backoff
    base_delay = 30
    delay_seconds = base_delay * (2 ** attempts)
    
    # Add jitter to prevent thundering herd
    jitter = rand(0.1..0.3) * delay_seconds
    (delay_seconds + jitter).to_i
  end

  # Mark as delivered
  def mark_delivered!(response_code, response_body = nil)
    update!(
      status: :delivered,
      delivered_at: Time.current,
      response_code: response_code,
      response_body: response_body&.truncate(1000) # Limit response body size
    )
  end

  # Mark as failed
  def mark_failed!(response_code = nil, response_body = nil)
    update!(
      status: :failed,
      response_code: response_code,
      response_body: response_body&.truncate(1000),
      last_attempted_at: Time.current
    )
  end

  # Increment attempt counter
  def increment_attempts!
    update!(
      attempts: attempts + 1,
      last_attempted_at: Time.current
    )
  end

  # Get organization through webhook_endpoint
  def organization
    webhook_endpoint.organization
  end

  # Check if event type is valid
  def valid_event_type?
    WebhookEndpoint::AVAILABLE_EVENTS.include?(event_type)
  end
end