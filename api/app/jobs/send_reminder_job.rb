class SendReminderJob < ApplicationJob
  queue_as :notifications

  # Called without arguments for batch processing (scheduled hourly),
  # or with a booking_id for single-booking reminders (legacy).
  def perform(booking_id = nil)
    if booking_id
      send_single_reminder(booking_id)
    else
      Reminders::SendReminderService.call
    end
  end

  private

  def send_single_reminder(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    return if booking.cancelled?
    return if booking.starts_at <= Time.current

    Notifications::SendReminderService.call(booking: booking)
  end
end
