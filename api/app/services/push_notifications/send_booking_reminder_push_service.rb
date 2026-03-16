# frozen_string_literal: true

module PushNotifications
  class SendBookingReminderPushService < ApplicationService
    attr_accessor :booking, :reminder_type

    validates :booking, presence: true
    validates :reminder_type, presence: true, inclusion: { in: %w[24h morning_of] }

    def call
      return validation_failure(self) unless valid?

      user = booking.user
      device_tokens = DeviceToken.active.for_user(user).pluck(:token)

      return success(sent: 0, reason: "no_device_tokens") if device_tokens.empty?

      tee_time = booking.tee_time
      course = tee_time.course

      title, body = build_message(course, tee_time)

      SendPushNotificationService.call(
        tokens: device_tokens,
        title: title,
        body: body,
        data: {
          type: "booking_reminder",
          booking_id: booking.id,
          confirmation_code: booking.confirmation_code,
          reminder_type: reminder_type
        },
        channel_id: "booking-reminders"
      )
    end

    private

    def build_message(course, tee_time)
      case reminder_type
      when "24h"
        [
          "Tee Time Tomorrow! ⛳",
          "#{course.name} at #{tee_time.formatted_time} — #{booking.players_count} player#{'s' if booking.players_count > 1}. See you on the course!"
        ]
      when "morning_of"
        [
          "Tee Time Today! 🏌️",
          "Your round at #{course.name} is at #{tee_time.formatted_time}. Have a great game!"
        ]
      end
    end
  end
end
