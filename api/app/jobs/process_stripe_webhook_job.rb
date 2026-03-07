class ProcessStripeWebhookJob < ApplicationJob
  queue_as :webhooks

  def perform(stripe_event_id, event_type, event_data)
    Rails.logger.info("Processing Stripe webhook: #{event_type} (#{stripe_event_id})")

    result = Payments::HandleStripeWebhookService.call(
      stripe_event_id: stripe_event_id,
      event_type: event_type,
      event_data: event_data
    )

    if result.failure?
      Rails.logger.error("Stripe webhook processing failed: #{result.error_messages}")
      raise StandardError, "Webhook processing failed: #{result.error_messages}"
    end

    Rails.logger.info("Successfully processed Stripe webhook: #{stripe_event_id}")
  end
end