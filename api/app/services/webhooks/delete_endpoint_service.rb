module Webhooks
  class DeleteEndpointService < ApplicationService
    attr_accessor :webhook_endpoint

    validates :webhook_endpoint, presence: true

    def call
      return validation_failure(self) unless valid?

      if webhook_endpoint.destroy
        success(webhook_endpoint: webhook_endpoint)
      else
        validation_failure(webhook_endpoint)
      end
    end
  end
end