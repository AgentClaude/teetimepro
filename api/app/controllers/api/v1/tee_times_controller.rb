class Api::V1::TeeTimesController < Api::V1::BaseController
  def index
    tee_times = build_tee_times_query

    paginated_tee_times = paginate(tee_times)

    render json: {
      data: tee_times_data(paginated_tee_times.includes(tee_sheet: :course)),
      meta: pagination_meta(paginated_tee_times)
    }
  end

  def show
    tee_time = find_tee_time(params[:id])

    render json: {
      data: tee_time_data(tee_time)
    }
  end

  private

  def build_tee_times_query
    # Start with base scope for the organization
    query = TeeTime.joins(tee_sheet: :course)
                   .where(courses: { organization_id: current_organization.id })

    # Filter by course if specified
    if params[:course_id].present?
      query = query.where(courses: { id: params[:course_id] })
    end

    # Filter by exact date
    if params[:date].present?
      date = Date.parse(params[:date])
      query = query.where(tee_sheets: { date: date })
    end

    # Filter by minimum available spots (alias: players)
    if params[:players].present?
      min = params[:players].to_i
      query = query.where(status: [:available, :partially_booked])
                   .where("tee_times.max_players - tee_times.booked_players >= ?", min)
    end

    # Filter by time preference
    if params[:time_preference].present?
      query = apply_time_preference(query, params[:time_preference], params[:date])
    end

    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      query = query.joins(:tee_sheet).where("tee_sheets.date >= ?", start_date)
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      query = query.joins(:tee_sheet).where("tee_sheets.date <= ?", end_date)
    end

    # Filter by availability
    if params[:status].present?
      case params[:status]
      when "available"
        query = query.where(status: [:available, :partially_booked])
      when "fully_booked"
        query = query.where(status: :fully_booked)
      when "blocked"
        query = query.where(status: [:blocked, :maintenance])
      end
    end

    # Filter by minimum available spots
    if params[:min_players].present?
      min_players = params[:min_players].to_i
      query = query.where("max_players - booked_players >= ?", min_players)
    end

    query.order("tee_sheets.date", :starts_at)
  end

  def find_tee_time(id)
    TeeTime.joins(tee_sheet: :course)
           .where(courses: { organization_id: current_organization.id })
           .find(id)
  end

  def apply_time_preference(query, preference, date_str)
    date = date_str ? Date.parse(date_str) : Date.current
    tz = current_organization.timezone || "UTC"

    range = case preference
            when "early_morning" then { start: 6, end: 8 }
            when "morning"       then { start: 7, end: 11 }
            when "midday"        then { start: 11, end: 13 }
            when "afternoon"     then { start: 12, end: 16 }
            when "twilight"      then { start: 15, end: 18 }
            else
              hour = preference.to_i
              if hour.between?(5, 20)
                { start: [hour - 1, 5].max, end: [hour + 1, 20].min }
              else
                nil
              end
            end

    return query unless range

    start_time = date.in_time_zone(tz).change(hour: range[:start])
    end_time = date.in_time_zone(tz).change(hour: range[:end])
    query.where(starts_at: start_time..end_time)
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