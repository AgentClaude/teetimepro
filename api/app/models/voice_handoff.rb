class VoiceHandoff < ApplicationRecord
  belongs_to :organization
  belongs_to :voice_call_log, optional: true

  enum :status, {
    pending: 'pending',
    connected: 'connected',
    completed: 'completed',
    missed: 'missed',
    cancelled: 'cancelled'
  }

  enum :reason, {
    billing_inquiry: 'billing_inquiry',
    complaint: 'complaint',
    group_event: 'group_event',
    tournament: 'tournament',
    manager_request: 'manager_request',
    other: 'other'
  }

  validates :call_sid, presence: true, uniqueness: true
  validates :caller_phone, presence: true
  validates :reason, presence: true
  validates :status, presence: true
  validates :transfer_to, presence: true
  validates :started_at, presence: true

  validates :connected_at, presence: true, if: -> { connected? || completed? }
  validates :completed_at, presence: true, if: -> { completed? }
  validates :resolution_notes, presence: true, if: -> { completed? }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :recent, ->(hours = 24) { where(started_at: hours.hours.ago..) }
  scope :by_reason, ->(reason_type) { where(reason: reason_type) }
  scope :active, -> { where(status: [:pending, :connected]) }
  scope :pending_handoffs, -> { where(status: :pending) }
  scope :completed_handoffs, -> { where(status: [:completed, :missed, :cancelled]) }

  before_validation :set_started_at, on: :create

  def duration_seconds
    return nil unless started_at && connected_at
    (completed_at || Time.current) - connected_at
  end

  def wait_duration_seconds
    return wait_seconds if wait_seconds.present?
    return nil unless started_at && connected_at
    connected_at - started_at
  end

  def active?
    pending? || connected?
  end

  def formatted_caller_phone
    return caller_phone unless caller_phone.match?(/^\+?1?(\d{10})$/)
    
    digits = caller_phone.gsub(/\D/, '')[-10..]
    "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
  end

  def caller_display_name
    caller_name.presence || formatted_caller_phone
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end
end