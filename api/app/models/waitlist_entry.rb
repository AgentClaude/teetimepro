# frozen_string_literal: true

class WaitlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :tee_time
  belongs_to :organization

  enum :status, { waiting: 0, notified: 1, expired: 2, cancelled: 3 }

  validates :players_requested, presence: true, numericality: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :tee_time_id, message: "is already on the waitlist for this tee time" }
  validate :tee_time_must_be_in_future, on: :create

  scope :active, -> { where(status: :waiting) }
  scope :for_tee_time, ->(tee_time) { where(tee_time: tee_time) }
  scope :for_organization, ->(org) { where(organization: org) }
  scope :by_position, -> { order(created_at: :asc) }

  delegate :starts_at, to: :tee_time
  delegate :course, to: :tee_time

  def notify!
    update!(status: :notified, notified_at: Time.current)
  end

  def expire!
    update!(status: :expired, expired_at: Time.current)
  end

  private

  def tee_time_must_be_in_future
    if tee_time && tee_time.starts_at <= Time.current
      errors.add(:tee_time, "must be in the future")
    end
  end
end
