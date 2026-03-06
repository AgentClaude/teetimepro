class Api::V1::CoursesController < Api::V1::BaseController
  def index
    courses = current_organization.courses
                                 .includes(:organization)
                                 .order(:name)

    paginated_courses = paginate(courses)

    render json: {
      data: courses_data(paginated_courses),
      meta: pagination_meta(paginated_courses)
    }
  end

  def show
    course = current_organization.courses.find(params[:id])

    render json: {
      data: course_data(course)
    }
  end

  private

  def courses_data(courses)
    courses.map { |course| course_data(course) }
  end

  def course_data(course)
    {
      id: course.id,
      name: course.name,
      description: course.description,
      address: course.address,
      phone: course.phone,
      website: course.website,
      holes: course.holes,
      par: course.par,
      yardage: course.yardage,
      rating: course.rating,
      slope: course.slope,
      interval_minutes: course.interval_minutes,
      first_tee_time: course.first_tee_time&.strftime("%H:%M"),
      last_tee_time: course.last_tee_time&.strftime("%H:%M"),
      max_players_per_slot: course.max_players_per_slot,
      rates: {
        weekday: course.weekday_rate&.format(symbol: false),
        weekend: course.weekend_rate&.format(symbol: false),
        twilight: course.twilight_rate&.format(symbol: false)
      },
      twilight_start_time: course.try(:twilight_start_time)&.strftime("%H:%M"),
      created_at: course.created_at.iso8601,
      updated_at: course.updated_at.iso8601
    }
  end
end