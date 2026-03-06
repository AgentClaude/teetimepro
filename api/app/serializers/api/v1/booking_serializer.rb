module Api
  module V1
    class BookingSerializer
      def initialize(booking)
        @booking = booking
      end

      def as_json
        {
          id: @booking.id,
          confirmation_code: @booking.confirmation_code,
          status: @booking.status,
          players_count: @booking.players_count,
          total: money_to_hash(@booking.total),
          notes: @booking.notes,
          cancelled_at: @booking.cancelled_at&.iso8601,
          checked_in_at: @booking.checked_in_at&.iso8601,
          tee_time: {
            id: @booking.tee_time.id,
            starts_at: @booking.tee_time.starts_at.iso8601,
            formatted_time: @booking.tee_time.formatted_time,
            date: @booking.tee_time.date.iso8601
          },
          course: {
            id: @booking.course.id,
            name: @booking.course.name
          },
          user: {
            id: @booking.user.id,
            name: @booking.user.name,
            email: @booking.user.email,
            phone: @booking.user.phone
          },
          players: @booking.booking_players.map do |player|
            {
              id: player.id,
              name: player.name,
              handicap: player.handicap,
              is_guest: player.is_guest
            }
          end,
          payment: payment_info,
          metadata: {
            cancellable: @booking.cancellable?,
            refundable: @booking.refundable?,
            late_cancel: @booking.late_cancel?
          },
          created_at: @booking.created_at.iso8601,
          updated_at: @booking.updated_at.iso8601
        }
      end

      def self.collection(bookings)
        bookings.map { |booking| new(booking).as_json }
      end

      private

      def money_to_hash(money_object)
        return nil unless money_object

        {
          amount: money_object.cents,
          currency: money_object.currency.to_s,
          formatted: money_object.format
        }
      end

      def payment_info
        return nil unless @booking.payment

        {
          id: @booking.payment.id,
          status: @booking.payment.status,
          method: @booking.payment.payment_method,
          amount: money_to_hash(@booking.payment.amount),
          processed_at: @booking.payment.processed_at&.iso8601
        }
      end
    end
  end
end