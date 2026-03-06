class VoiceCallLog < ApplicationRecord
  belongs_to :organization
  belongs_to :course, optional: true

  validates :channel, inclusion: { in: %w[browser twilio] }
  validates :status, inclusion: { in: %w[in_progress completed error] }
  validates :started_at, presence: true

  scope :for_organization, ->(org) { where(organization: org) }
  scope :recent, -> { order(started_at: :desc) }

  def message_count
    transcript&.count { |e| e["type"] == "transcript" } || 0
  end

  def function_call_count
    transcript&.count { |e| e["type"] == "function_call" } || 0
  end

  def booking_created?
    transcript&.any? { |e| e["type"] == "function_result" && e["name"] == "create_booking" && e.dig("result", "success") } || false
  end
end
