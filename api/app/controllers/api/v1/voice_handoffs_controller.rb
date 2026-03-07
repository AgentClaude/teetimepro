class Api::V1::VoiceHandoffsController < Api::V1::BaseController
  def index
    handoffs = VoiceHandoff.for_organization(current_organization)
                          .includes(:voice_call_log)
                          .order(started_at: :desc)

    handoffs = handoffs.where(status: params[:status]) if params[:status].present?
    handoffs = handoffs.where(reason: params[:reason]) if params[:reason].present?
    handoffs = handoffs.active if params[:active_only] == 'true'

    paginated = paginate(handoffs)

    render json: {
      data: paginated.map { |handoff| handoff_data(handoff) },
      meta: pagination_meta(paginated)
    }
  end

  def show
    handoff = VoiceHandoff.for_organization(current_organization)
                         .includes(:voice_call_log)
                         .find(params[:id])

    render json: {
      data: handoff_data(handoff, include_details: true)
    }
  end

  def create
    result = Voice::InitiateHandoffService.call(
      organization: current_organization,
      call_sid: handoff_params[:call_sid],
      caller_phone: handoff_params[:caller_phone],
      caller_name: handoff_params[:caller_name],
      reason: handoff_params[:reason],
      reason_detail: handoff_params[:reason_detail],
      voice_call_log_id: handoff_params[:voice_call_log_id]
    )

    if result.success?
      render json: {
        data: {
          handoff: handoff_data(result.handoff),
          transfer_number: result.transfer_number,
          handoff_id: result.handoff_id,
          already_exists: result.already_exists || false
        }
      }, status: result.already_exists ? :ok : :created
    else
      render_service_error(result)
    end
  end

  def update
    handoff = VoiceHandoff.for_organization(current_organization).find(params[:id])

    result = Voice::UpdateHandoffService.call(
      handoff: handoff,
      status: handoff_params[:status],
      staff_name: handoff_params[:staff_name],
      resolution_notes: handoff_params[:resolution_notes],
      wait_seconds: handoff_params[:wait_seconds]
    )

    if result.success?
      render json: {
        data: handoff_data(result.handoff, include_details: true)
      }
    else
      render_service_error(result)
    end
  end

  private

  def handoff_params
    params.permit(
      :call_sid, :caller_phone, :caller_name, :reason, :reason_detail,
      :voice_call_log_id, :status, :staff_name, :resolution_notes, :wait_seconds
    )
  end

  def handoff_data(handoff, include_details: false)
    data = {
      id: handoff.id,
      organization_id: handoff.organization_id,
      voice_call_log_id: handoff.voice_call_log_id,
      call_sid: handoff.call_sid,
      caller_phone: handoff.caller_phone,
      caller_name: handoff.caller_name,
      formatted_caller_phone: handoff.formatted_caller_phone,
      caller_display_name: handoff.caller_display_name,
      reason: handoff.reason,
      status: handoff.status,
      transfer_to: handoff.transfer_to,
      staff_name: handoff.staff_name,
      wait_seconds: handoff.wait_seconds,
      started_at: handoff.started_at&.iso8601,
      connected_at: handoff.connected_at&.iso8601,
      completed_at: handoff.completed_at&.iso8601,
      created_at: handoff.created_at.iso8601,
      updated_at: handoff.updated_at.iso8601,
      active: handoff.active?
    }

    if include_details
      data.merge!(
        reason_detail: handoff.reason_detail,
        resolution_notes: handoff.resolution_notes,
        duration_seconds: handoff.duration_seconds&.to_i,
        wait_duration_seconds: handoff.wait_duration_seconds&.to_i,
        voice_call_log: handoff.voice_call_log ? call_log_summary(handoff.voice_call_log) : nil
      )
    end

    data
  end

  def call_log_summary(log)
    {
      id: log.id,
      course_id: log.course_id,
      course_name: log.course&.name,
      channel: log.channel,
      status: log.status,
      duration_seconds: log.duration_seconds,
      started_at: log.started_at&.iso8601,
      ended_at: log.ended_at&.iso8601
    }
  end
end