module Api
  module V1
    class TeeTimeSerializer
      def initialize(tee_time)
        @tee_time = tee_time
      end

      def as_json
        {
          id: @tee_time.id,
          starts_at: @tee_time.starts_at.iso8601,
          formatted_time: @tee_time.formatted_time,
          date: @tee_time.date.iso8601,
          status: @tee_time.status,
          max_players: @tee_time.max_players,
          booked_players: @tee_time.booked_players,
          available_spots: @tee_time.available_spots,
          price: money_to_hash(@tee_time.price),
          course: {
            id: @tee_time.course.id,
            name: @tee_time.course.name
          },
          created_at: @tee_time.created_at.iso8601,
          updated_at: @tee_time.updated_at.iso8601
        }
      end

      def self.collection(tee_times)
        tee_times.map { |tee_time| new(tee_time).as_json }
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
    end
  end
end