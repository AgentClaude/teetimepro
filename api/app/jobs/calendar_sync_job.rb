class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform(booking_id, action)
    booking = Booking.find_by(id: booking_id)
    return unless booking

    # Don't sync for cancelled bookings unless we're deleting the event
    return if booking.cancelled? && action != 'delete'

    result = Calendars::SyncBookingService.call(
      booking: booking,
      action: action
    )

    if result.failure?
      Rails.logger.error "Calendar sync failed for booking #{booking.id}: #{result.errors.join(', ')}"
    else
      Rails.logger.info "Calendar sync completed for booking #{booking.id}: #{action}"
    end
  rescue => e
    Rails.logger.error "Calendar sync job failed for booking #{booking_id}: #{e.message}"
    raise # This will trigger retry logic
  end
end