# frozen_string_literal: true

class EmailCampaign < ApplicationRecord
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :email_messages, dependent: :destroy

  enum :status, {
    draft: 0,
    scheduled: 1,
    sending: 2,
    completed: 3,
    cancelled: 4,
    failed: 5
  }

  enum :recipient_filter, {
    all: "all",
    members_only: "members_only",
    recent_bookers: "recent_bookers",
    inactive: "inactive",
    lapsed: "lapsed",
    segment: "segment"
  }, prefix: :filter

  validates :name, presence: true
  validates :subject, presence: true
  validates :body_html, presence: true
  validates :lapsed_days, presence: true, numericality: { greater_than: 0 }
  validates :recurrence_interval_days, numericality: { greater_than: 0, allow_nil: true }
  validates :status, presence: true
  validates :recipient_filter, presence: true

  scope :by_organization, ->(org) { where(organization: org) }
  scope :pending_send, -> { where(status: :scheduled).where("scheduled_at <= ?", Time.current) }
  scope :automated, -> { where(is_automated: true) }
  scope :due_for_automation, -> do
    automated.where(status: :completed)
      .where("completed_at + INTERVAL recurrence_interval_days DAY <= ?", Time.current)
  end

  def progress_percentage
    return 0 if total_recipients.zero?

    ((sent_count + failed_count).to_f / total_recipients * 100).round(1)
  end

  def open_rate_percentage
    return 0 if sent_count.zero?

    (opened_count.to_f / sent_count * 100).round(1)
  end

  def click_rate_percentage
    return 0 if sent_count.zero?

    (clicked_count.to_f / sent_count * 100).round(1)
  end

  def can_send?
    draft? || scheduled?
  end

  def can_cancel?
    draft? || scheduled? || sending?
  end

  def ready_for_next_automation?
    return false unless is_automated?
    return false unless completed?
    return false if recurrence_interval_days.nil?

    completed_at + recurrence_interval_days.days <= Time.current
  end
end