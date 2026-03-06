class Api::V1::BookingsController < Api::V1::BaseController
  def index
    bookings = build_bookings_query.includes(
      :tee_time, 
      :user, 
      :booking_players,
      :payment,
      tee_time: { tee_sheet: :course }
    )

    paginated_bookings = paginate(bookings)

    render_paginated(
      paginated_bookings,
      paginated_bookings,
      Api::V1::BookingSerializer
    )
  end

  def show
    booking = find_booking(params[:id])

    render json: {
      data: Api::V1::BookingSerializer.new(booking).as_json
    }
  end

  def create
    user_result = find_or_create_api_user(booking_params[:user])
    return render_service_error(user_result) unless user_result.success?

    result = Bookings::CreateBookingService.call(
      organization: current_organization,
      tee_time: find_tee_time(booking_params[:tee_time_id]),
      user: user_result.data[:user],
      players_count: booking_params[:players_count],
      payment_method_id: booking_params[:payment_method_id],
      player_names: booking_params[:player_names]
    )

    if result.success?
      render json: {
        data: Api::V1::BookingSerializer.new(result.data[:booking]).as_json
      }, status: :created
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
      render json: {
        data: Api::V1::BookingSerializer.new(result.data[:booking]).as_json
      }
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
    Users::FindOrCreateApiUserService.call(
      organization: current_organization,
      email: user_params[:email],
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      phone: user_params[:phone]
    )
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