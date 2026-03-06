module Webhooks
  class DispatchEventService < ApplicationService
    attr_accessor :organization, :event_type, :payload

    validates :organization, :event_type, :payload, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Invalid event type"]) unless valid_event_type?

      # Find all active webhook endpoints for this organization that subscribe to this event
      endpoints = WebhookEndpoint.for_organization(organization)
                                 .active
                                 .subscribed_to_event(event_type)

      webhook_events = []
      
      endpoints.find_each do |endpoint|
        # Create a webhook event for each endpoint
        webhook_event = WebhookEvent.create!(
          webhook_endpoint: endpoint,
          event_type: event_type,
          payload: payload
        )

        # Enqueue delivery job
        WebhookDeliveryJob.perform_later(webhook_event.id)
        
        webhook_events << webhook_event
      end

      success(
        webhook_events: webhook_events,
        endpoints_count: endpoints.count
      )
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def valid_event_type?
      WebhookEndpoint::AVAILABLE_EVENTS.include?(event_type)
    end
  end
end