class WebhookDeliveryJob < ApplicationJob
  queue_as :webhooks

  # Disable default retry since we handle retries in the service
  retry_on StandardError, attempts: 1

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find(webhook_event_id)
    
    # Skip if event is no longer pending (already delivered or permanently failed)
    return unless webhook_event.pending?

    result = Webhooks::DeliverWebhookService.call(webhook_event: webhook_event)
    
    # Log result for monitoring
    Rails.logger.info("Webhook delivery result: #{result.success? ? 'success' : 'failure'} " \
                      "for event #{webhook_event_id} to #{webhook_event.webhook_endpoint.url}")
    
    unless result.success?
      Rails.logger.warn("Webhook delivery failed: #{result.error_messages}")
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("WebhookEvent #{webhook_event_id} not found, skipping delivery")
  end
end