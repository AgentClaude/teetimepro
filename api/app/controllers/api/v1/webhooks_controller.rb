class Api::V1::WebhooksController < Api::V1::BaseController
  before_action :set_webhook_endpoint, only: [:show, :update, :destroy, :test]

  def index
    webhook_endpoints = WebhookEndpoint.for_organization(current_organization)
                                      .includes(:webhook_events)
                                      .order(:created_at)

    paginated_endpoints = paginate(webhook_endpoints)

    render json: {
      data: webhook_endpoints_data(paginated_endpoints),
      meta: pagination_meta(paginated_endpoints)
    }
  end

  def show
    render json: {
      data: webhook_endpoint_data(@webhook_endpoint, include_events: true)
    }
  end

  def create
    result = Webhooks::CreateEndpointService.call(
      organization: current_organization,
      url: webhook_params[:url],
      events: webhook_params[:events],
      description: webhook_params[:description],
      secret: webhook_params[:secret]
    )

    if result.success?
      render_service_success(
        OpenStruct.new(data: webhook_endpoint_data(result.webhook_endpoint)),
        status: :created
      )
    else
      render_service_error(result)
    end
  end

  def update
    result = Webhooks::UpdateEndpointService.call(
      webhook_endpoint: @webhook_endpoint,
      url: webhook_params[:url],
      events: webhook_params[:events],
      description: webhook_params[:description],
      active: webhook_params[:active]
    )

    if result.success?
      render_service_success(
        OpenStruct.new(data: webhook_endpoint_data(result.webhook_endpoint))
      )
    else
      render_service_error(result)
    end
  end

  def destroy
    result = Webhooks::DeleteEndpointService.call(webhook_endpoint: @webhook_endpoint)

    if result.success?
      render json: { message: "Webhook endpoint deleted successfully" }, status: :ok
    else
      render_service_error(result)
    end
  end

  def test
    # Send a test event
    test_payload = {
      event: "test",
      timestamp: Time.current.iso8601,
      webhook_endpoint_id: @webhook_endpoint.id,
      organization_id: current_organization.id,
      test_data: {
        message: "This is a test webhook event",
        sent_at: Time.current.iso8601
      }
    }

    result = Webhooks::DispatchEventService.call(
      organization: current_organization,
      event_type: "booking.created", # Use a real event type for testing
      payload: test_payload
    )

    if result.success?
      render json: {
        message: "Test webhook sent successfully",
        webhook_events: result.webhook_events.map(&:id)
      }
    else
      render_service_error(result)
    end
  end

  private

  def set_webhook_endpoint
    @webhook_endpoint = WebhookEndpoint.for_organization(current_organization).find(params[:id])
  end

  def webhook_params
    params.require(:webhook).permit(
      :url, :description, :active, :secret,
      events: []
    )
  end

  def webhook_endpoints_data(endpoints)
    endpoints.map { |endpoint| webhook_endpoint_data(endpoint) }
  end

  def webhook_endpoint_data(endpoint, include_events: false)
    data = {
      id: endpoint.id,
      url: endpoint.url,
      events: endpoint.events,
      active: endpoint.active,
      description: endpoint.description,
      success_rate: endpoint.success_rate,
      created_at: endpoint.created_at.iso8601,
      updated_at: endpoint.updated_at.iso8601
    }

    if include_events
      recent_events = endpoint.recent_events(20)
      data[:recent_events] = recent_events.map do |event|
        {
          id: event.id,
          event_type: event.event_type,
          status: event.status,
          attempts: event.attempts,
          response_code: event.response_code,
          last_attempted_at: event.last_attempted_at&.iso8601,
          delivered_at: event.delivered_at&.iso8601,
          created_at: event.created_at.iso8601
        }
      end
    end

    data
  end
end
