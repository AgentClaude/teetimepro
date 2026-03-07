module Webhooks
  class UpdateEndpointService < ApplicationService
    attr_accessor :webhook_endpoint, :url, :events, :description, :active

    validates :webhook_endpoint, presence: true

    def call
      return validation_failure(self) unless valid?

      # Only update provided attributes
      attributes = {}
      attributes[:url] = url if url.present?
      attributes[:events] = Array(events) if events.present?
      attributes[:description] = description if description.present?
      attributes[:active] = active if !active.nil?

      if webhook_endpoint.update(attributes)
        success(webhook_endpoint: webhook_endpoint)
      else
        validation_failure(webhook_endpoint)
      end
    end
  end
end
