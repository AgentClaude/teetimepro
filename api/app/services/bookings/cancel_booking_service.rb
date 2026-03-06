module Bookings
  class CancelBookingService < ApplicationService
    attr_accessor :booking, :reason, :refund

    validates :booking, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Booking is already cancelled"]) if booking.cancelled?
      return failure(["Cannot cancel past bookings"]) if booking.starts_at <= Time.current

      ActiveRecord::Base.transaction do
        # Check cancellation policy
        if booking.late_cancel?
          Rails.logger.info("Late cancellation for booking #{booking.id}")
        end

        # Process refund if requested and eligible
        if refund && booking.payment&.completed?
          refund_result = Payments::RefundPaymentService.call(
            payment: booking.payment,
            reason: reason || "Customer requested cancellation"
          )

          unless refund_result.success?
            raise ActiveRecord::Rollback
            return refund_result
          end
        end

        # Release tee time spots
        booking.tee_time.release_spots!(booking.players_count)

        # Update booking status
        booking.update!(
          status: :cancelled,
          cancelled_at: Time.current,
          cancellation_reason: reason
        )

        # Send cancellation notification
        notify_cancellation(booking)

        success(booking: booking)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def notify_cancellation(booking)
      # Fire-and-forget notification
      Rails.logger.info("Booking #{booking.confirmation_code} cancelled for #{booking.user.email}")
    end
  end
end
