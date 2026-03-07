module Voice
  class CancelVoiceBookingService < ApplicationService
    attr_accessor :organization, :booking_id, :reason

    validates :organization, presence: true
    validates :booking_id, presence: true

    def call
      return validation_failure(self) unless valid?

      booking = nil

      ActiveRecord::Base.transaction do
        booking = find_and_validate_booking
        return failure(["Booking not found or not in pending state"]) unless booking

        # Cancel the booking
        booking.status = :cancelled
        booking.cancelled_at = Time.current
        booking.cancellation_reason = reason.presence || "Voice booking cancelled by caller"
        booking.notes = "Voice booking cancelled during confirmation"
        
        unless booking.save
          return validation_failure(booking)
        end
      end

      success(
        booking: booking,
        booking_id: booking.id,
        confirmation_code: booking.confirmation_code,
        status: booking.status,
        cancelled_at: booking.cancelled_at,
        cancellation_reason: booking.cancellation_reason,
        date: booking.tee_time.starts_at.strftime("%Y-%m-%d"),
        formatted_time: booking.tee_time.formatted_time,
        players: booking.players_count,
        course_name: booking.tee_time.course.name
      )

    rescue StandardError => e
      Rails.logger.error "Voice booking cancellation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      failure(["Failed to cancel voice booking: #{e.message}"])
    end

    private

    def find_and_validate_booking
      Booking.joins(tee_time: { tee_sheet: :course })
             .where(id: booking_id, courses: { organization_id: organization.id })
             .where(status: :pending_voice_confirmation)
             .first
    end
  end
end