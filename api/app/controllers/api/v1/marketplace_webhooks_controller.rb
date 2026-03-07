class Api::V1::MarketplaceWebhooksController < Api::V1::BaseController
  skip_before_action :authenticate_api_key!, only: [:receive]
  before_action :verify_marketplace_signature

  # POST /api/v1/marketplace_webhooks/:provider
  def receive
    provider = params[:provider]
    event_type = params[:event_type] || request.headers["X-Marketplace-Event"]

    case event_type
    when "booking.created"
      handle_booking_created
    when "booking.cancelled"
      handle_booking_cancelled
    when "listing.expired"
      handle_listing_expired
    else
      render json: { status: "ignored", event_type: event_type }, status: :ok
    end
  end

  private

  def handle_booking_created
    connection = find_connection
    return render_not_found("Connection") unless connection

    result = Marketplace::HandleBookingService.call(
      connection: connection,
      external_listing_id: params[:listing_id],
      external_booking_id: params[:booking_id],
      golfer_name: params.dig(:golfer, :name),
      golfer_email: params.dig(:golfer, :email),
      golfer_phone: params.dig(:golfer, :phone),
      players_count: params[:players_count].to_i
    )

    if result.success?
      render json: {
        status: "accepted",
        confirmation_code: result.data[:booking].confirmation_code
      }, status: :ok
    else
      render json: { status: "rejected", errors: result.errors }, status: :unprocessable_entity
    end
  end

  def handle_booking_cancelled
    connection = find_connection
    return render_not_found("Connection") unless connection

    listing = connection.marketplace_listings.find_by(
      external_listing_id: params[:listing_id]
    )

    if listing&.booked?
      booking_id = listing.metadata["booking_id"]
      if booking_id
        Bookings::CancelBookingService.call(
          booking: Booking.find(booking_id),
          reason: "Cancelled via #{connection.provider_label} marketplace"
        )
      end
      listing.mark_cancelled!
    end

    render json: { status: "ok" }, status: :ok
  end

  def handle_listing_expired
    connection = find_connection
    return render_not_found("Connection") unless connection

    listing = connection.marketplace_listings.find_by(
      external_listing_id: params[:listing_id]
    )

    listing&.mark_expired!

    render json: { status: "ok" }, status: :ok
  end

  def find_connection
    MarketplaceConnection.find_by(
      provider: params[:provider],
      external_course_id: params[:course_id]
    )
  end

  def verify_marketplace_signature
    # Each marketplace provider uses different signature verification
    # In production, implement provider-specific HMAC verification
    signature = request.headers["X-Marketplace-Signature"]

    unless signature.present?
      render json: { error: "Missing signature" }, status: :unauthorized
      return
    end

    # Provider-specific verification would go here
    true
  end

  def render_not_found(resource)
    render json: { error: "#{resource} not found" }, status: :not_found
  end
end
