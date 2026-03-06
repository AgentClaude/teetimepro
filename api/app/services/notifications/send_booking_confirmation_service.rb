module Notifications
  class SendBookingConfirmationService < ApplicationService
    attr_accessor :booking

    validates :booking, presence: true

    def call
      return validation_failure(self) unless valid?

      user = booking.user
      tee_time = booking.tee_time
      course = tee_time.course

      message = build_confirmation_message(user, tee_time, course)

      # Send SMS if phone number available
      if user.respond_to?(:phone) && user.phone.present?
        send_sms(user.phone, message)
      end

      # Log the notification
      Rails.logger.info(
        "Booking confirmation sent for #{booking.confirmation_code} to #{user.email}"
      )

      success(
        booking: booking,
        message: message,
        delivered: true
      )
    rescue StandardError => e
      # Notification failures should not break the booking flow
      Rails.logger.error("Failed to send booking confirmation: #{e.message}")
      success(booking: booking, delivered: false, error: e.message)
    end

    private

    def build_confirmation_message(user, tee_time, course)
      <<~MSG.strip
        Hi #{user.first_name}! Your tee time is confirmed.
        #{course.name} - #{tee_time.formatted_time} on #{tee_time.date.strftime('%B %d, %Y')}
        Players: #{booking.players_count}
        Confirmation: #{booking.confirmation_code}
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
