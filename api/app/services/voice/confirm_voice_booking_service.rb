module Voice
  class ConfirmVoiceBookingService < ApplicationService
    attr_accessor :organization, :booking_id

    validates :organization, presence: true
    validates :booking_id, presence: true

    def call
      return validation_failure(self) unless valid?

      booking = nil

      ActiveRecord::Base.transaction do
        booking = find_and_validate_booking
        return failure(["Booking not found or not in pending state"]) unless booking

        # Validate the tee time is still available and not in the past
        unless booking.tee_time.starts_at > Time.current
          return failure(["This tee time is no longer available - it's in the past"])
        end

        # Double-check available spots (in case another booking was made)
        if booking.tee_time.available_spots < booking.players_count
          return failure(["This tee time is no longer available - insufficient spots"])
        end

        # Confirm the booking
        booking.status = :confirmed
        booking.notes = "Voice booking confirmed"
        
        unless booking.save
          return validation_failure(booking)
        end
      end

      success(
        booking: booking,
        booking_id: booking.id,
        confirmation_code: booking.confirmation_code,
        status: booking.status,
        date: booking.tee_time.starts_at.strftime("%Y-%m-%d"),
        formatted_time: booking.tee_time.formatted_time,
        players: booking.players_count,
        total_cents: booking.total_cents,
        course_name: booking.tee_time.course.name
      )

    rescue StandardError => e
      Rails.logger.error "Voice booking confirmation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      failure(["Failed to confirm voice booking: #{e.message}"])
    end

    private

    def find_and_validate_booking
      booking = Booking.joins(tee_time: { tee_sheet: :course })
                      .where(id: booking_id, courses: { organization_id: organization.id })
                      .where(status: :pending_voice_confirmation)
                      .first

      # Check if booking is expired (older than 5 minutes)
      if booking && booking.created_at < 5.minutes.ago
        # Auto-cancel expired pending bookings
        booking.update!(status: :cancelled, cancellation_reason: "Voice booking timeout - not confirmed within 5 minutes")
        return nil
      end

      booking
    end
  end
end