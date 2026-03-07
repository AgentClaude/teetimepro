module Notifications
  class SendBookingConfirmationService < ApplicationService
    attr_accessor :booking

    validates :booking, presence: true

    def call
      return validation_failure(self) unless valid?

      user = booking.user
      tee_time = booking.tee_time
      course = tee_time.course

      sms_sent = false
      email_sent = false
      errors = []

      # Send SMS if phone number available
      if user.respond_to?(:phone) && user.phone.present?
        sms_result = send_sms_notification(user, tee_time, course)
        sms_sent = sms_result[:success]
        errors << sms_result[:error] if sms_result[:error]
      end

      # Send email if email address available
      if user.email.present?
        email_result = send_email_notification
        email_sent = email_result[:success]
        errors << email_result[:error] if email_result[:error]
      end

      # Log the notification attempt
      delivery_methods = []
      delivery_methods << "SMS" if sms_sent
      delivery_methods << "email" if email_sent
      delivered_via = delivery_methods.join(" and ")

      if sms_sent || email_sent
        Rails.logger.info(
          "Booking confirmation sent for #{booking.confirmation_code} via #{delivered_via} to #{user.email}"
        )
      else
        Rails.logger.warn(
          "Failed to send booking confirmation for #{booking.confirmation_code}: #{errors.join(', ')}"
        )
      end

      success(
        booking: booking,
        sms_sent: sms_sent,
        email_sent: email_sent,
        delivered: sms_sent || email_sent,
        errors: errors
      )
    rescue StandardError => e
      # Notification failures should not break the booking flow
      Rails.logger.error("Failed to send booking confirmation: #{e.message}")
      success(booking: booking, sms_sent: false, email_sent: false, delivered: false, error: e.message)
    end

    private

    def send_sms_notification(user, tee_time, course)
      return { success: false, error: "No phone number available" } unless user.phone.present?
      return { success: false, error: "Twilio not configured" } unless ENV["TWILIO_ACCOUNT_SID"].present?

      message = build_confirmation_message(user, tee_time, course)
      
      client = Twilio::REST::Client.new(
        ENV.fetch("TWILIO_ACCOUNT_SID"),
        ENV.fetch("TWILIO_AUTH_TOKEN")
      )

      client.messages.create(
        from: ENV.fetch("TWILIO_PHONE_NUMBER"),
        to: user.phone,
        body: message
      )

      { success: true }
    rescue StandardError => e
      { success: false, error: "SMS failed: #{e.message}" }
    end

    def send_email_notification
      return { success: false, error: "No email address available" } unless booking.user.email.present?

      BookingMailer.confirmation_email(booking).deliver_later

      { success: true }
    rescue StandardError => e
      { success: false, error: "Email failed: #{e.message}" }
    end

    def build_confirmation_message(user, tee_time, course)
      <<~MSG.strip
        Hi #{user.first_name}! Your tee time is confirmed.
        #{course.name} - #{tee_time.formatted_time} on #{tee_time.date.strftime('%B %d, %Y')}
        Players: #{booking.players_count}
        Confirmation: #{booking.confirmation_code}
      MSG
    end
  end
end
