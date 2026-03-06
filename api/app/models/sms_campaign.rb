# frozen_string_literal: true

class SmsCampaign < ApplicationRecord
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :sms_messages, dependent: :destroy

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
    custom: "custom"
  }, prefix: :filter

  validates :name, presence: true
  validates :message_body, presence: true, length: { maximum: 1600 }
  validates :status, presence: true
  validates :recipient_filter, presence: true

  scope :by_organization, ->(org) { where(organization: org) }
  scope :pending_send, -> { where(status: :scheduled).where("scheduled_at <= ?", Time.current) }

  def progress_percentage
    return 0 if total_recipients.zero?

    ((sent_count + failed_count).to_f / total_recipients * 100).round(1)
  end

  def can_send?
    draft? || scheduled?
  end

  def can_cancel?
    draft? || scheduled? || sending?
  end
end
