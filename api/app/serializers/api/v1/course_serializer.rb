module Api
  module V1
    class CourseSerializer
      def initialize(course)
        @course = course
      end

      def as_json
        {
          id: @course.id,
          name: @course.name,
          description: @course.description,
          holes: @course.holes,
          par: @course.par,
          yardage: @course.yardage,
          rating: @course.rating,
          slope: @course.slope,
          address: @course.address,
          city: @course.city,
          state: @course.state,
          zip_code: @course.zip_code,
          phone: @course.phone,
          email: @course.email,
          website: @course.website,
          first_tee_time: @course.first_tee_time&.strftime('%H:%M'),
          last_tee_time: @course.last_tee_time&.strftime('%H:%M'),
          interval_minutes: @course.interval_minutes,
          max_players_per_slot: @course.max_players_per_slot,
          rates: {
            weekday: money_to_hash(@course.weekday_rate),
            weekend: money_to_hash(@course.weekend_rate),
            twilight: money_to_hash(@course.twilight_rate)
          },
          created_at: @course.created_at.iso8601,
          updated_at: @course.updated_at.iso8601
        }
      end

      def self.collection(courses)
        courses.map { |course| new(course).as_json }
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