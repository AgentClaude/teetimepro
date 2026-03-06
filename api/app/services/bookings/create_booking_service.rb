module Bookings
  class CreateBookingService < ApplicationService
    attr_accessor :organization, :tee_time, :user, :players_count,
                  :payment_method_id, :player_names

    validates :tee_time, :user, :players_count, presence: true

    def call
      return validation_failure(self) unless valid?

      # Check availability
      availability = CheckAvailabilityService.call(
        tee_time: tee_time,
        players_count: players_count
      )
      return availability unless availability.success?

      ActiveRecord::Base.transaction do
        # Create the booking
        booking = Booking.create!(
          tee_time: tee_time,
          user: user,
          players_count: players_count,
          total_cents: calculate_total,
          total_currency: "USD",
          status: :confirmed,
          notes: ""
        )

        # Create booking players
        create_booking_players(booking)

        # Book the spots on the tee time
        tee_time.book_spots!(players_count)

        # Process payment if payment method provided
        if payment_method_id.present?
          payment_result = Payments::ProcessPaymentService.call(
            booking: booking,
            payment_method_id: payment_method_id,
            stripe_account_id: organization&.stripe_account_id
          )

          unless payment_result.success?
            raise ActiveRecord::Rollback
            return payment_result
          end
        end

        # Send confirmation (async)
        Notifications::SendBookingConfirmationService.call(booking: booking)

        # Schedule reminder
        reminder_time = tee_time.starts_at - 24.hours
        if reminder_time > Time.current
          SendReminderJob.set(wait_until: reminder_time).perform_later(booking.id)
        end

        # Dispatch webhook event
        webhook_payload = build_booking_webhook_payload(booking)
        Webhooks::DispatchEventService.call(
          organization: booking.organization,
          event_type: "booking.created",
          payload: webhook_payload
        )

        success(booking: booking)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def calculate_total
      rate = tee_time.price_cents || tee_time.course.default_rate_for(
        tee_time.date,
        tee_time.starts_at
      )&.cents || 0

      rate * players_count
    end

    def create_booking_players(booking)
      names = player_names || []
      players_count.times do |i|
        BookingPlayer.create!(
          booking: booking,
          name: names[i] || (i.zero? ? user.full_name : "Player #{i + 1}")
        )
      end
    end

    def build_booking_webhook_payload(booking)
      {
        id: booking.id,
        type: "booking",
        attributes: {
          confirmation_code: booking.confirmation_code,
          status: booking.status,
          players_count: booking.players_count,
          total_cents: booking.total_cents,
          total_currency: booking.total_currency,
          notes: booking.notes,
          created_at: booking.created_at.iso8601
        },
        tee_time: {
          id: booking.tee_time.id,
          starts_at: booking.tee_time.starts_at.iso8601,
          date: booking.tee_time.date.iso8601
        },
        course: {
          id: booking.course.id,
          name: booking.course.name
        },
        user: {
          id: booking.user.id,
          email: booking.user.email,
          first_name: booking.user.first_name,
          last_name: booking.user.last_name
        },
        timestamp: Time.current.iso8601,
        organization_id: booking.organization.id
      }
    end
  end
end
