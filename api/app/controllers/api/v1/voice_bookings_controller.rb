class Api::V1::VoiceBookingsController < Api::V1::BaseController
  def reserve
    result = Voice::BookVoiceCallService.call(
      organization: current_organization,
      tee_time_id: voice_booking_params[:tee_time_id],
      players_count: voice_booking_params[:players_count],
      caller_name: voice_booking_params[:caller_name],
      caller_phone: voice_booking_params[:caller_phone]
    )

    if result.success?
      render json: {
        data: {
          booking_id: result.booking_id,
          confirmation_code: result.confirmation_code,
          status: "pending_voice_confirmation",
          date: result.date,
          formatted_time: result.formatted_time,
          players: result.players,
          price_per_player_cents: result.price_per_player_cents,
          total_cents: result.total_cents,
          course_name: result.course_name
        }
      }, status: :created
    else
      render_service_error(result)
    end
  end

  def confirm
    result = Voice::ConfirmVoiceBookingService.call(
      organization: current_organization,
      booking_id: confirm_cancel_params[:booking_id]
    )

    if result.success?
      render json: {
        data: {
          booking_id: result.booking_id,
          confirmation_code: result.confirmation_code,
          status: result.status,
          date: result.date,
          formatted_time: result.formatted_time,
          players: result.players,
          total_cents: result.total_cents,
          course_name: result.course_name
        }
      }
    else
      render_service_error(result)
    end
  end

  def cancel
    result = Voice::CancelVoiceBookingService.call(
      organization: current_organization,
      booking_id: confirm_cancel_params[:booking_id],
      reason: confirm_cancel_params[:reason]
    )

    if result.success?
      render json: {
        data: {
          booking_id: result.booking_id,
          confirmation_code: result.confirmation_code,
          status: result.status,
          cancelled_at: result.cancelled_at,
          cancellation_reason: result.cancellation_reason,
          date: result.date,
          formatted_time: result.formatted_time,
          players: result.players,
          course_name: result.course_name
        }
      }
    else
      render_service_error(result)
    end
  end

  private

  def voice_booking_params
    params.permit(
      :tee_time_id, :players_count, :caller_name, :caller_phone
    )
  end

  def confirm_cancel_params
    params.permit(:booking_id, :reason)
  end
end