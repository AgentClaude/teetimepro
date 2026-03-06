class Api::V1::CoursesController < Api::V1::BaseController
  def index
    courses = current_organization.courses
                                 .includes(:organization)
                                 .order(:name)

    paginated_courses = paginate(courses)

    render_paginated(
      paginated_courses,
      paginated_courses,
      Api::V1::CourseSerializer
    )
  end

  def show
    course = current_organization.courses.find(params[:id])
    
    render json: {
      data: Api::V1::CourseSerializer.new(course).as_json
    }
  end
end