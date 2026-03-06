class Api::V1::TeeTimesController < Api::V1::BaseController
  def index
    result = TeeSheets::SearchTeeTimesService.call(
      organization: current_organization,
      date: params[:date],
      players: params[:players]&.to_i,
      time_preference: params[:time_preference],
      course_id: params[:course_id],
      start_date: params[:start_date],
      end_date: params[:end_date],
      status: params[:status],
      limit: params[:limit]&.to_i
    )

    unless result.success?
      return render json: { error: result.error_message }, status: :unprocessable_entity
    end

    tee_times = result.tee_times
    response = {
      data: tee_times_data(tee_times)
    }

    if result.respond_to?(:alternatives) && result.alternatives.present?
      response[:alternatives] = tee_times_data(result.alternatives)
      response[:message] = result.message
    end

    render json: response
  end

  def show
    tee_time = find_tee_time(params[:id])

    render json: {
      data: tee_time_data(tee_time)
    }
  end

  private

  def find_tee_time(id)
    TeeTime.joins(tee_sheet: :course)
           .where(courses: { organization_id: current_organization.id })
           .find(id)
  end

  def tee_times_data(tee_times)
    tee_times.map { |tee_time| tee_time_data(tee_time) }
  end

  def tee_time_data(tee_time)
    {
      id: tee_time.id,
      starts_at: tee_time.starts_at.iso8601,
      formatted_time: tee_time.formatted_time,
      status: tee_time.status,
      max_players: tee_time.max_players,
      booked_players: tee_time.booked_players,
      available_spots: tee_time.available_spots,
      price: tee_time.price&.format(symbol: false),
      price_cents: tee_time.price_cents,
      date: tee_time.date.iso8601,
      course: {
        id: tee_time.course.id,
        name: tee_time.course.name
      },
      created_at: tee_time.created_at.iso8601,
      updated_at: tee_time.updated_at.iso8601
    }
  end
end