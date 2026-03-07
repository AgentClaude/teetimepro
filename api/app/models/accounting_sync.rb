class AccountingSync < ApplicationRecord
  belongs_to :accounting_integration
  belongs_to :syncable, polymorphic: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, failed: 3 }
  
  validates :sync_type, presence: true, inclusion: { in: %w[invoice payment refund] }
  validates :accounting_integration, presence: true
  validates :syncable, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :failed, -> { where(status: :failed) }
  scope :retryable, -> { failed.where('next_retry_at <= ?', Time.current) }
  scope :for_organization, ->(org) {
    joins(:accounting_integration).where(accounting_integrations: { organization_id: org.id })
  }

  # Constants for retry logic
  MAX_RETRY_COUNT = 3
  RETRY_DELAYS = [5.minutes, 30.minutes, 2.hours].freeze

  # Start the sync process
  def start!
    update!(
      status: :in_progress,
      started_at: Time.current,
      error_message: nil,
      error_at: nil
    )
  end

  # Mark sync as completed
  def complete!(external_id, external_data = nil)
    update!(
      status: :completed,
      external_id: external_id,
      external_data: external_data,
      completed_at: Time.current,
      error_message: nil,
      error_at: nil
    )
  end

  # Mark sync as failed with retry logic
  def fail!(error_message)
    self.retry_count += 1
    self.error_message = error_message
    self.error_at = Time.current
    self.status = :failed

    if retry_count <= MAX_RETRY_COUNT
      delay_index = [retry_count - 1, RETRY_DELAYS.length - 1].min
      self.next_retry_at = RETRY_DELAYS[delay_index].from_now
    end

    save!
  end

  # Check if this sync can be retried
  def retryable?
    failed? && retry_count <= MAX_RETRY_COUNT && next_retry_at <= Time.current
  end

  # Reset for retry
  def reset_for_retry!
    update!(
      status: :pending,
      error_message: nil,
      error_at: nil,
      started_at: nil
    )
  end

  # Human readable sync type
  def sync_type_humanized
    case sync_type
    when 'invoice'
      'Invoice'
    when 'payment'
      'Payment'
    when 'refund'
      'Refund'
    else
      sync_type.titleize
    end
  end

  # Organization through accounting integration
  def organization
    accounting_integration.organization
  end

  # Provider name
  def provider
    accounting_integration.provider
  end

  # Duration of sync
  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end
end