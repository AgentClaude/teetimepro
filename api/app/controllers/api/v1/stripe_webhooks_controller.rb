class Api::V1::StripeWebhooksController < Api::V1::BaseController
  # Skip API key authentication for Stripe webhooks
  skip_before_action :authenticate_api_key!
  skip_before_action :set_organization_from_api_key

  before_action :verify_stripe_signature

  def create
    # Extract event data
    stripe_event_id = @stripe_event.id
    event_type = @stripe_event.type
    event_data = @stripe_event.data.to_h

    # Enqueue job for async processing
    ProcessStripeWebhookJob.perform_later(
      stripe_event_id,
      event_type,
      event_data
    )

    # Return 200 immediately to Stripe
    render json: { received: true }, status: :ok

  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error("Stripe webhook signature verification failed: #{e.message}")
    render json: { error: "Invalid signature" }, status: :unauthorized

  rescue StandardError => e
    Rails.logger.error("Stripe webhook processing error: #{e.message}")
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  private

  def verify_stripe_signature
    payload = request.body.read
    signature = request.headers['Stripe-Signature']

    webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']
    unless webhook_secret
      Rails.logger.error("STRIPE_WEBHOOK_SECRET not configured")
      render json: { error: "Webhook secret not configured" }, status: :internal_server_error
      return
    end

    unless signature
      Rails.logger.error("Missing Stripe signature header")
      render json: { error: "Invalid signature" }, status: :unauthorized
      return
    end

    begin
      @stripe_event = Stripe::Webhook.construct_event(
        payload,
        signature,
        webhook_secret
      )
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe signature verification failed: #{e.message}")
      render json: { error: "Invalid signature" }, status: :unauthorized
      return
    end
  end
end