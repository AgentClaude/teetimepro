class SendReminderJob < ApplicationJob
  queue_as :notifications

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    return if booking.cancelled?
    return if booking.starts_at <= Time.current

    Notifications::SendReminderService.call(booking: booking)
  end
end
