class Api::V1::BookingsController < Api::V1::BaseController
  def index
    bookings = build_bookings_query

    paginated_bookings = paginate(bookings)

    render json: {
      data: bookings_data(paginated_bookings.includes(:tee_time, :user, :course)),
      meta: pagination_meta(paginated_bookings)
    }
  end

  def show
    booking = find_booking(params[:id])

    render json: {
      data: booking_data(booking)
    }
  end

  def create
    # Support both nested (booking: { ... }) and flat params (from voice bot)
    bp = params[:booking].present? ? booking_params : {}
    user_attrs = bp[:user] || {}

    tee_time_id = bp[:tee_time_id] || params[:tee_time_id]
    players_count = bp[:players_count] || params[:players_count]
    phone = user_attrs[:phone] || params[:phone]
    first_name = user_attrs[:first_name] || params[:first_name]
    last_name = user_attrs[:last_name] || params[:last_name]

    user = find_or_create_api_user(
      user_attrs.presence || { phone: phone, first_name: first_name.presence || "Guest", last_name: last_name.presence || "Caller" }
    )
    return unless user # find_or_create_api_user renders error

    result = Bookings::CreateBookingService.call(
      organization: current_organization,
      tee_time: find_tee_time(tee_time_id),
      user: user,
      players_count: players_count,
      payment_method_id: bp[:payment_method_id],
      player_names: bp[:player_names]
    )

    if result.success?
      render_service_success(
        OpenStruct.new(data: booking_data(result.data[:booking])),
        status: :created
      )
    else
      render_service_error(result)
    end
  end

  def cancel
    booking = find_booking(params[:id])

    result = Bookings::CancelBookingService.call(
      booking: booking,
      reason: params[:reason]
    )

    if result.success?
      render_service_success(
        OpenStruct.new(data: booking_data(result.booking))
      )
    else
      render_service_error(result)
    end
  end

  private

  def build_bookings_query
    query = Booking.for_organization(current_organization)

    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      query = query.joins(:tee_time).where("tee_times.starts_at >= ?", start_date.beginning_of_day)
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      query = query.joins(:tee_time).where("tee_times.starts_at <= ?", end_date.end_of_day)
    end

    # Filter by status
    if params[:status].present?
      query = query.where(status: params[:status])
    end

    # Filter by course
    if params[:course_id].present?
      query = query.joins(tee_time: { tee_sheet: :course })
                   .where(courses: { id: params[:course_id] })
    end

    # Filter by confirmation code
    if params[:confirmation_code].present?
      query = query.where(confirmation_code: params[:confirmation_code].upcase)
    end

    query.order(created_at: :desc)
  end

  def find_booking(id)
    Booking.for_organization(current_organization).find(id)
  end

  def find_tee_time(id)
    TeeTime.joins(tee_sheet: :course)
           .where(courses: { organization_id: current_organization.id })
           .find(id)
  end

  def find_or_create_api_user(user_params)
    result = Users::FindOrCreateApiUserService.call(
      organization: current_organization,
      email: user_params[:email],
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      phone: user_params[:phone]
    )

    unless result.success?
      render_service_error(result)
      return nil
    end

    result.data[:user]
  end

  def bookings_data(bookings)
    bookings.map { |booking| booking_data(booking) }
  end

  def booking_data(booking)
    {
      id: booking.id,
      confirmation_code: booking.confirmation_code,
      status: booking.status,
      players_count: booking.players_count,
      total: booking.total.format(symbol: false),
      total_cents: booking.total_cents,
      notes: booking.notes,
      tee_time: {
        id: booking.tee_time.id,
        starts_at: booking.tee_time.starts_at.iso8601,
        formatted_time: booking.tee_time.formatted_time,
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
        last_name: booking.user.last_name,
        phone: booking.user.phone
      },
      booking_players: booking.booking_players.map do |player|
        {
          id: player.id,
          name: player.name
        }
      end,
      created_at: booking.created_at.iso8601,
      updated_at: booking.updated_at.iso8601
    }
  end

  def booking_params
    params.require(:booking).permit(
      :tee_time_id,
      :players_count,
      :payment_method_id,
      user: [:email, :first_name, :last_name, :phone],
      player_names: []
    )
  end
end
