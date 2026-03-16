class NotificationPreference < ApplicationRecord
  has_paper_trail

  belongs_to :user

  # Constant for available reminder hours options
  REMINDER_HOURS_OPTIONS = [1, 2, 4, 12, 24, 48].freeze

  # Validation for reminder hours before booking
  validates :reminder_hours_before, inclusion: { in: REMINDER_HOURS_OPTIONS }

  # Default preferences for new users
  def self.default_preferences
    {
      email_booking_confirmation: true,
      email_booking_cancellation: true,
      email_booking_reminder: true,
      email_marketing: false,
      sms_booking_confirmation: true,
      sms_booking_cancellation: false,
      sms_booking_reminder: true,
      sms_marketing: false,
      push_booking_confirmation: true,
      push_booking_cancellation: true,
      push_booking_reminder: true,
      push_marketing: false,
      reminder_hours_before: 24
    }
  end
end