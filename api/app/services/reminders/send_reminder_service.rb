# frozen_string_literal: true

module Reminders
  class SendReminderService < ApplicationService
    REMINDER_24H_WINDOW = { min: 20.hours, max: 28.hours }.freeze

    def call
      results = { reminders_24h: 0, morning_reminders: 0, errors: [] }

      send_24h_reminders(results)
      send_morning_reminders(results)

      Rails.logger.info(
        "SendReminderService completed: " \
        "24h=#{results[:reminders_24h]}, " \
        "morning=#{results[:morning_reminders]}, " \
        "errors=#{results[:errors].size}"
      )

      success(results)
    end

    private

    def send_24h_reminders(results)
      bookings_needing_24h_reminder.find_each do |booking|
        send_reminder(booking, :reminder_24h, results)
      end
    end

    def send_morning_reminders(results)
      bookings_needing_morning_reminder.find_each do |booking|
        send_reminder(booking, :morning_of, results)
      end
    end

    def send_reminder(booking, type, results)
      organization = booking.organization
      mailer_method = type

      BookingReminderMailer.public_send(mailer_method, booking: booking, organization: organization).deliver_now

      timestamp_column = type == :reminder_24h ? :reminder_sent_at : :morning_reminder_sent_at
      booking.update_column(timestamp_column, Time.current)

      counter_key = type == :reminder_24h ? :reminders_24h : :morning_reminders
      results[counter_key] += 1
    rescue StandardError => e
      Rails.logger.error(
        "Failed to send #{type} reminder for booking #{booking.id}: #{e.message}"
      )
      results[:errors] << { booking_id: booking.id, type: type, error: e.message }
    end

    def bookings_needing_24h_reminder
      window_start = REMINDER_24H_WINDOW[:min].from_now
      window_end = REMINDER_24H_WINDOW[:max].from_now

      Booking
        .joins(:tee_time)
        .where(status: [:confirmed, :checked_in])
        .where(reminder_sent_at: nil)
        .where(tee_times: { starts_at: window_start..window_end })
    end

    def bookings_needing_morning_reminder
      today_start = Time.current.beginning_of_day
      today_end = Time.current.end_of_day

      Booking
        .joins(:tee_time)
        .where(status: [:confirmed, :checked_in])
        .where(morning_reminder_sent_at: nil)
        .where(tee_times: { starts_at: Time.current..today_end })
    end
  end
end
