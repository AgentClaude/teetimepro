class StripeEvent < ApplicationRecord
  enum :status, { pending: 0, processed: 1, failed: 2 }

  validates :stripe_event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :payload, presence: true

  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :unprocessed, -> { where.not(status: :processed) }

  def self.already_processed?(stripe_event_id)
    exists?(stripe_event_id: stripe_event_id, status: :processed)
  end

  def mark_processed!
    update!(status: :processed, processed_at: Time.current, error_message: nil)
  end

  def mark_failed!(error)
    update!(status: :failed, error_message: error.to_s)
  end
end