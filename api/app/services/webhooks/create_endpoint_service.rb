module Webhooks
  class CreateEndpointService < ApplicationService
    attr_accessor :organization, :url, :events, :description, :secret

    validates :organization, :url, :events, presence: true

    def call
      return validation_failure(self) unless valid?

      webhook_endpoint = WebhookEndpoint.new(
        organization: organization,
        url: url,
        events: Array(events),
        description: description,
        secret: secret
      )

      if webhook_endpoint.save
        success(webhook_endpoint: webhook_endpoint)
      else
        validation_failure(webhook_endpoint)
      end
    end
  end
end