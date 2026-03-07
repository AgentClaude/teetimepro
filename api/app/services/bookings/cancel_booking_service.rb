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

        # Broadcast real-time notification
        broadcast_notification(booking)

        # Remove from calendar (async)
        CalendarSyncJob.perform_later(booking.id, 'delete')

        success(booking: booking)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def broadcast_notification(booking)
      ActionCable.server.broadcast(
        "notifications_#{booking.organization.id}",
        {
          type: "booking.cancelled",
          booking: {
            id: booking.id,
            confirmation_code: booking.confirmation_code,
            status: booking.status,
            players_count: booking.players_count,
            total_cents: booking.total_cents,
            customer_name: booking.user.full_name,
            tee_time: booking.tee_time.formatted_time,
            date: booking.tee_time.date.iso8601,
            course_name: booking.course.name,
            cancellation_reason: booking.cancellation_reason
          },
          timestamp: Time.current.iso8601
        }
      )
    end

    def notify_cancellation(booking)
      # Send cancellation email
      Notifications::SendBookingEmailService.call(
        booking: booking,
        email_type: "cancellation"
      )

      Rails.logger.info("Booking #{booking.confirmation_code} cancelled for #{booking.user.email}")
    end
  end
end
