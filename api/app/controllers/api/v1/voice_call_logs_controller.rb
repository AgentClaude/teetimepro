class Api::V1::VoiceCallLogsController < Api::V1::BaseController
  def index
    logs = VoiceCallLog.for_organization(current_organization)
                       .recent

    logs = logs.where(course_id: params[:course_id]) if params[:course_id].present?
    logs = logs.where(channel: params[:channel]) if params[:channel].present?
    logs = logs.where(status: params[:status]) if params[:status].present?

    paginated = paginate(logs)

    render json: {
      data: paginated.map { |log| call_log_data(log) },
      meta: pagination_meta(paginated)
    }
  end

  def show
    log = VoiceCallLog.for_organization(current_organization).find(params[:id])

    render json: {
      data: call_log_data(log, include_transcript: true)
    }
  end

  def create
    log = VoiceCallLog.new(
      organization: current_organization,
      course_id: log_params[:course_id],
      call_sid: log_params[:call_sid],
      channel: log_params[:channel] || "browser",
      caller_phone: log_params[:caller_phone],
      caller_name: log_params[:caller_name],
      status: log_params[:status] || "completed",
      duration_seconds: log_params[:duration_seconds],
      transcript: log_params[:transcript] || [],
      summary: build_summary(log_params[:transcript] || []),
      started_at: log_params[:started_at] || Time.current,
      ended_at: log_params[:ended_at] || Time.current
    )

    if log.save
      render json: { data: call_log_data(log) }, status: :created
    else
      render json: { error: log.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def log_params
    permitted = params.permit(
      :course_id, :call_sid, :channel, :caller_phone, :caller_name,
      :status, :duration_seconds, :started_at, :ended_at
    )
    # Permit transcript as raw JSON array — strong params can't handle
    # arbitrary nested structures in function_call results
    permitted[:transcript] = params[:transcript].map(&:to_unsafe_h) if params[:transcript].present?
    permitted
  end

  def build_summary(transcript)
    messages = transcript.select { |e| e["type"] == "transcript" }
    function_calls = transcript.select { |e| e["type"] == "function_call" }
    function_results = transcript.select { |e| e["type"] == "function_result" }

    # Find the successful booking result
    booking_result = function_results.select { |e| e["name"] == "create_booking" }
                                     .find { |e| e.dig("result", "success") == true }
    confirmation_code = booking_result&.dig("result", "confirmation_code")

    summary = {
      message_count: messages.size,
      user_messages: messages.count { |e| e["role"] == "user" },
      agent_messages: messages.count { |e| e["role"] == "agent" },
      function_calls: function_calls.size,
      booking_created: confirmation_code.present?,
      confirmation_code: confirmation_code
    }

    # Enrich with actual booking data if found
    if confirmation_code.present?
      booking = Booking.for_organization(current_organization)
                       .find_by(confirmation_code: confirmation_code)
      if booking
        summary[:booking_id] = booking.id
        summary[:booking_status] = booking.status
        summary[:booking_players] = booking.players_count
        summary[:booking_time] = booking.tee_time.formatted_time
        summary[:booking_date] = booking.tee_time.date.iso8601
      end
    end

    summary
  end

  def call_log_data(log, include_transcript: false)
    data = {
      id: log.id,
      course_id: log.course_id,
      course_name: log.course&.name,
      call_sid: log.call_sid,
      channel: log.channel,
      caller_phone: log.caller_phone,
      caller_name: log.caller_name,
      status: log.status,
      duration_seconds: log.duration_seconds,
      summary: log.summary,
      started_at: log.started_at&.iso8601,
      ended_at: log.ended_at&.iso8601,
      created_at: log.created_at.iso8601
    }

    data[:transcript] = log.transcript if include_transcript

    data
  end
end
