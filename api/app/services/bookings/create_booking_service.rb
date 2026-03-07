module Bookings
  class CreateBookingService < ApplicationService
    attr_accessor :organization, :tee_time, :user, :players_count,
                  :payment_method_id, :player_names, :player_details,
                  :loyalty_redemption_code

    validates :tee_time, :user, :players_count, presence: true

    def call
      return validation_failure(self) unless valid?

      # Check availability
      availability = CheckAvailabilityService.call(
        tee_time: tee_time,
        players_count: players_count
      )
      return availability unless availability.success?

      # Validate loyalty redemption if provided
      redemption = nil
      discount_cents = 0
      if loyalty_redemption_code.present?
        redemption = LoyaltyRedemption
          .joins(:loyalty_account)
          .where(code: loyalty_redemption_code, status: :pending)
          .where(loyalty_accounts: { user_id: user.id })
          .first

        if redemption.nil?
          return failure(["Invalid or expired loyalty redemption code"])
        end

        discount_cents = calculate_loyalty_discount(redemption)
      end

      ActiveRecord::Base.transaction do
        total = calculate_total
        total_after_discount = [total - discount_cents, 0].max

        # Create the booking
        booking = Booking.create!(
          tee_time: tee_time,
          user: user,
          players_count: players_count,
          total_cents: total_after_discount,
          total_currency: "USD",
          status: :confirmed,
          notes: ""
        )

        # Create booking players
        create_booking_players(booking)

        # Apply loyalty redemption
        if redemption.present?
          redemption.update!(status: :applied, booking_id: booking.id) if redemption.respond_to?(:booking_id)
          redemption.update!(status: :applied) unless redemption.respond_to?(:booking_id)
        end

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

        # Broadcast real-time notification
        broadcast_notification(booking, "booking.created")

        # Sync to calendar (async)
        CalendarSyncJob.perform_later(booking.id, 'create')

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

    def calculate_loyalty_discount(redemption)
      reward = redemption.loyalty_reward
      return 0 unless reward

      case reward.reward_type
      when "discount_percentage"
        ((calculate_total * (reward.discount_value || 0)) / 100.0).round
      when "discount_fixed"
        ((reward.discount_value || 0) * 100).round # discount_value is in dollars
      when "free_round"
        calculate_total # Full discount for one player's worth
      else
        0
      end
    end

    def create_booking_players(booking)
      if player_details.present?
        player_details.each_with_index do |detail, i|
          BookingPlayer.create!(
            booking: booking,
            name: detail[:name].presence || (i.zero? ? user.full_name : "Player #{i + 1}"),
            email: detail[:email],
            phone: detail[:phone]
          )
        end

        # Fill remaining slots if fewer details than players_count
        remaining = players_count - player_details.size
        remaining.times do |i|
          idx = player_details.size + i
          BookingPlayer.create!(
            booking: booking,
            name: "Player #{idx + 1}"
          )
        end
      else
        names = player_names || []
        players_count.times do |i|
          BookingPlayer.create!(
            booking: booking,
            name: names[i] || (i.zero? ? user.full_name : "Player #{i + 1}")
          )
        end
      end
    end

    def broadcast_notification(booking, event)
      ActionCable.server.broadcast(
        "notifications_#{booking.organization.id}",
        {
          type: event,
          booking: {
            id: booking.id,
            confirmation_code: booking.confirmation_code,
            status: booking.status,
            players_count: booking.players_count,
            total_cents: booking.total_cents,
            customer_name: booking.user.full_name,
            tee_time: booking.tee_time.formatted_time,
            date: booking.tee_time.date.iso8601,
            course_name: booking.course.name
          },
          timestamp: Time.current.iso8601
        }
      )
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
