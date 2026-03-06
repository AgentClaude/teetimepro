module Notifications
  class SendReminderService < ApplicationService
    attr_accessor :booking

    validates :booking, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Booking is cancelled"]) if booking.cancelled?
      return failure(["Tee time has passed"]) if booking.starts_at <= Time.current

      user = booking.user
      tee_time = booking.tee_time
      course = tee_time.course

      hours_until = ((tee_time.starts_at - Time.current) / 1.hour).round
      message = build_reminder_message(user, tee_time, course, hours_until)

      if user.respond_to?(:phone) && user.phone.present?
        send_sms(user.phone, message)
      end

      Rails.logger.info(
        "Reminder sent for booking #{booking.confirmation_code}, " \
        "tee time in #{hours_until} hours"
      )

      success(booking: booking, message: message, hours_until: hours_until)
    rescue StandardError => e
      Rails.logger.error("Failed to send reminder: #{e.message}")
      success(booking: booking, delivered: false, error: e.message)
    end

    private

    def build_reminder_message(user, tee_time, course, hours_until)
      <<~MSG.strip
        Reminder: #{user.first_name}, your tee time at #{course.name} is in #{hours_until} hours!
        Time: #{tee_time.formatted_time} on #{tee_time.date.strftime('%B %d, %Y')}
        Players: #{booking.players_count}
        Confirmation: #{booking.confirmation_code}
        See you on the course! ⛳
      MSG
    end

    def send_sms(phone_number, message)
      return unless ENV["TWILIO_ACCOUNT_SID"].present?

      client = Twilio::REST::Client.new(
        ENV.fetch("TWILIO_ACCOUNT_SID"),
        ENV.fetch("TWILIO_AUTH_TOKEN")
      )

      client.messages.create(
        from: ENV.fetch("TWILIO_PHONE_NUMBER"),
        to: phone_number,
        body: message
      )
    end
  end
end
