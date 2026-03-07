module Types
  class PublicQueryType < Types::BaseObject
    # Public course info by slug
    field :public_course, Types::CourseType, null: true do
      argument :slug, String, required: true
    end
    def public_course(slug:)
      Course.joins(:organization).find_by(slug: slug)
    end

    # Public available tee times (no auth required)
    field :public_available_tee_times, [Types::TeeTimeType], null: false do
      argument :course_slug, String, required: true
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :players, Integer, required: false
      argument :time_preference, String, required: false # morning, afternoon, twilight
    end
    def public_available_tee_times(course_slug:, date:, players: 1, time_preference: nil)
      course = Course.joins(:organization).find_by!(slug: course_slug)
      tee_sheet = course.tee_sheets.find_by(date: date)
      return [] unless tee_sheet

      tee_times = tee_sheet.tee_times.available_for(players).order(:starts_at)

      # Filter by time preference if provided
      case time_preference&.downcase
      when 'morning'
        tee_times = tee_times.where('EXTRACT(hour FROM starts_at) < 12')
      when 'afternoon'
        tee_times = tee_times.where('EXTRACT(hour FROM starts_at) BETWEEN 12 AND 16')
      when 'twilight'
        tee_times = tee_times.where('EXTRACT(hour FROM starts_at) > 16')
      end

      tee_times
    end
  end
end